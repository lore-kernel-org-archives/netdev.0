From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: build bug: ipt_CONNMARK.c: undefined reference to
 `need_ip_conntrack'
Date: Sat, 19 Nov 2005 22:56:23 +0100
Message-ID: <m3wtj42tfc.fsf@defiant.localdomain>
References: <m364qolfuv.fsf@defiant.localdomain>
	<200511191930.jAJJUJEv022269@toshiba.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: laforge@netfilter.org, netfilter-devel@lists.netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750928AbVKSV4b@vger.kernel.org>
To: Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>
In-Reply-To: <200511191930.jAJJUJEv022269@toshiba.co.jp> (Yasuyuki KOZAKAI's
 message of "Sun, 20 Nov 2005 04:30:18 +0900 (JST)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp> writes:

>>   LD      init/built-in.o
>>   LD      .tmp_vmlinux1
>> net/built-in.o(.init.text+0x1adb): In function `init':
>> ipt_CONNMARK.c: undefined reference to `need_ip_conntrack'
>> make[2]: *** [.tmp_vmlinux1] Error 1
>> 
>> Last merged Linus' git: b286e39207237e2f6929959372bf66d9a8d05a82
>> (i.e., current 2.6.15rc1+).
>
> Thanks for report. Could you check this patch ?

Builds correctly. Thanks.
-- 
Krzysztof Halasa
