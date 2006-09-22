From: "Boris B. Zhmurov" <bb@kernelpanic.ru>
Subject: Re: Update of the r8169 branch
Date: Fri, 22 Sep 2006 22:55:51 +0400
Message-ID: <451431B7.3080608@kernelpanic.ru>
References: <20060726215840.GA4032@electric-eye.fr.zoreil.com> <4511A4F0.6050101@kernelpanic.ru> <20060920214010.GA7879@electric-eye.fr.zoreil.com> <4512B475.1000703@kernelpanic.ru> <20060921165156.GC496@electric-eye.fr.zoreil.com> <4512ED7A.40001@kernelpanic.ru> <20060921210743.GA5083@electric-eye.fr.zoreil.com>
Reply-To: bb@kernelpanic.ru
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, mbockol@carleton.edu, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.nkosino.ru ([81.222.178.7]:8661 "EHLO mail.nkosino.ru")
	by vger.kernel.org with ESMTP id S932108AbWIVSzx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2006 14:55:53 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20060921210743.GA5083@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:

>> Is there any chance to get linux worked at least as fast, as freebsd-6.1 
>> with small udp packets?
>> Any help will be more than welcome!
>> Please, CC: me, due to I'm not subscribed to netdev@vger.kernel.org.
> 
> Can you publish dmesg, vmstat 1 and /proc/interrupts somewhere ?

ftp://bb-work.kernelpanic.ru/pub/dmesg
ftp://bb-work.kernelpanic.ru/pub/vmstat
ftp://bb-work.kernelpanic.ru/pub/interrupts

>> # Thu Sep 21 10:31:58 2006
>> #
>> CONFIG_X86_32=y
>> CONFIG_GENERIC_TIME=y
>> CONFIG_LOCKDEP_SUPPORT=y
> 
> Disable

[......]

Thanks Francois, after your suggestions, network performance was twice 
increased, but I'm still loosing to freebsd:


previous .config (server's input):
             input          (em0)           output
    packets  errs      bytes    packets  errs      bytes colls
      38630     0    4248702          1     0        206     0
      35849     0    3943298          1     0        170     0
      38264     0    4208994          1     0        170     0

new .config (server's input):
            input          (em0)           output
    packets  errs      bytes    packets  errs      bytes colls
      90431     0    9947370          1     0        182     0
      90504     0    9955400          1     0        294     0
      90494     0    9954300          1     0        182     0


P.S. I couldn't disable the following things due to bzImage build errors:
CONFIG_GENERIC_TIME
CONFIG_X86=y
CONFIG_MMU=y
CONFIG_GENERIC_IOMAP=y
CONFIG_DMI=y


-- 
Boris B. Zhmurov
System/Network Administrator
mailto: bb@kernelpanic.ru
"wget http://kernelpanic.ru/bb_public_key.pgp -O - | gpg --import"

