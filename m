From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch] bonding: move procfs into bond_procfs.c
Date: Fri, 04 Mar 2011 17:08:45 +0800
Message-ID: <4D70AC1D.4080705@redhat.com>
References: <1298896204-6521-1-git-send-email-amwang@redhat.com> <20110302.221707.260068518.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, fubar@us.ibm.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110302.221707.260068518.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2011=E5=B9=B403=E6=9C=8803=E6=97=A5 14:17, David Miller =E5=86=
=99=E9=81=93:
> From: Amerigo Wang<amwang@redhat.com>
> Date: Mon, 28 Feb 2011 20:30:04 +0800
>
>> bond_main.c is bloating, separate the procfs code out,
>> move them to bond_procfs.c
>>
>> Signed-off-by: WANG Cong<amwang@redhat.com>
>
> Please use Makefile rules to conditionally compile the new bond_procf=
s.o
> file, instead of wrapping almost the entire file with an ifdef.
>
> Put the dummy no-PROC_FS function stubs, as inlines, in bonding.h
>

Ok, will do it in the next update.

Thanks!
