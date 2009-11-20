From: Dan Carpenter <error27.lkml@gmail.com>
Subject: Re: [RFC-PATCH] libiscsi dhcp handler
Date: Fri, 20 Nov 2009 15:29:24 +0200
Message-ID: <b263e5900911200529n1c002097q48a625d1bcda4db6@mail.gmail.com>
References: <4B014F95.8000906@chelsio.com>
	 <20091116.051835.125328285.davem@davemloft.net>
	 <4B01577E.2020003@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, michaelc@cs.wisc.edu,
	open-iscsi@googlegroups.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, James.Bottomley@suse.de,
	kxie@chelsio.com
To: Rakesh Ranjan <rakesh@chelsio.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753450AbZKTN3w@vger.kernel.org>
In-Reply-To: <4B01577E.2020003@chelsio.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/16/09, Rakesh Ranjan <rakesh@chelsio.com> wrote:
> David Miller wrote:
>> From: Rakesh Ranjan <rakesh@chelsio.com>
>> Date: Mon, 16 Nov 2009 18:41:49 +0530
>>
>>> Herein attached patches to support dhcp based provisioning for iSCS=
I
>>> offload capable cards. I have made dhcp code as generic as possible=
,
>>> please go through the code. Based on the feedback I will submit fin=
al
>>> version of these patches.
>>
>> You can't really add objects to the build before the patch that
>> adds the source for that object.
>>
>
> Hi david,
>
> Fixed patch attached.
>
> Regards
> Rakesh Ranjan
>

The header file changes cause warnings in allmodconfig.

   CC [M]  drivers/scsi/be2iscsi/be_iscsi.o
+In file included from drivers/scsi/be2iscsi/be_iscsi.c:21:
+include/scsi/libiscsi.h:445: warning: =91struct net_device=92 declared
inside parameter list
+include/scsi/libiscsi.h:445: warning: its scope is only this
definition or declaration, which is probably not what you want
+include/scsi/libiscsi.h:447: warning: =91struct sk_buff=92 declared
inside parameter list
+include/scsi/libiscsi.h:447: warning: =91struct net_device=92 declared
inside parameter list

regards,
dan carpenter
