From: "Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>
Subject: Re: possible BUG while using CUPS
Date: Mon, 13 Aug 2007 17:39:47 +0200
Message-ID: <6bffcb0e0708130839v27b4269dqfde702c410b33fd0@mail.gmail.com>
References: <46BD762F.4060801@xs4all.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Netdev <netdev@vger.kernel.org>
To: "Udo van den Heuvel" <udovdh@xs4all.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.180]:57724 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S942835AbXHMPju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Aug 2007 11:39:50 -0400
Received: by wa-out-1112.google.com with SMTP id v27so1880588wah
        for <netdev@vger.kernel.org>; Mon, 13 Aug 2007 08:39:48 -0700 (PDT)
In-Reply-To: <46BD762F.4060801@xs4all.nl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Udo,

On 11/08/07, Udo van den Heuvel <udovdh@xs4all.nl> wrote:
> Using Cups 1.2.12 on Linux 2.6.22.1.
> Managing a printer from a Win2K workstation via the http interface.
> I am at: http://box:631/printers
> I click Set as default.
> I see:
> 426 Upgrade Required
>
> You must access this page using the URL
> https://box:631/admin/?op=set-as-default&printer_name=HP_DESKJET_3820_USB_1.
>
> I clikc that link and hear the ping-ping of the BUG:

This is very interesting. Can you reproduce this bug?

>
> BUG: unable to handle kernel paging request at virtual address 730ca542
>  printing eip:
> 730ca542
> *pde = 00000000
> Oops: 0000 [#1]
> PREEMPT
> Modules linked in: pwc nls_utf8 cifs sch_tbf ipt_recent xt_string
> xt_MARK xt_length xt_tcpmss xt_mac xt_mark w83627hf hwmon_vid eeprom sit
> tunnel4 nf_nat_h323 nf_conntrack_h323 nf_nat_ftp nf_conntrack_ftp
> ipt_tos ipt_REDIRECT nf_nat_irc nf_conntrack_irc ipt_owner ipt_ttl ipv6
> ipt_MASQUERADE iptable_nat nf_nat xt_NOTRACK iptable_raw ipt_TOS
> iptable_mangle ipt_LOG xt_TCPMSS xt_limit xt_state ipt_TARPIT ipt_REJECT
> iptable_filter binfmt_misc lp nvram loop snd_via82xx snd_ac97_codec
> ac97_bus snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq
> snd_pcm_oss snd_mixer_oss snd_pcm compat_ioctl32 videodev snd_timer
> snd_page_alloc snd_mpu401_uart snd_rawmidi v4l2_common snd_seq_device
> v4l1_compat parport_pc parport snd usblp i2c_viapro uhci_hcd
> CPU:    0
> EIP:    0060:[<730ca542>]    Not tainted VLI
> EFLAGS: 00010292   (2.6.22.1 #2)
> EIP is at 0x730ca542
> eax: 00000000   ebx: a69845a0   ecx: 00000000   edx: 00000000
> esi: 1057e3db   edi: 67c88dd0   ebp: 898c1ad5   esp: d9f97f18
> ds: 007b   es: 007b   fs: 0000  gs: 0033  ss: 0068
> Process cupsd (pid: 2220, ti=d9f96000 task=db549420 task.ti=d9f96000)
> Stack: b717a69a 240c98ab c2e35cdc 2f6eea16 64cf0972 c0a5a2b1 ba2d3d30
> f026206d
>        3301069b 39222156 d15922e5 eb1da2a4 656caba4 023f7970 33d43992
> cc0c5c41
>        63ed81fc 5c760bf7 fe3db5c3 7cdbd9fc ba114508 0ff827b8 b51f3690
> 9e64614f
> Call Trace:
>  [<c0103aa5>] show_trace_log_lvl+0x1a/0x2f
>  [<c0103b57>] show_stack_log_lvl+0x9d/0xa5
>  [<c0103d2c>] show_registers+0x1cd/0x2e3
>  [<c0103f40>] die+0xfe/0x200
>  [<c010f899>] do_page_fault+0x432/0x505
>  [<c02ff72a>] error_code+0x6a/0x70
>  =======================
> Code:  Bad EIP value.
> EIP: [<730ca542>] 0x730ca542 SS:ESP 0068:d9f97f18
>
>
> This is on a VIA Epia EK8000. ksymoops did not really help me, this is
> all output I got.
>
> Ideas?

BTW. Please try 2.6.22.2.

Regards,
Michal

-- 
LOG
http://www.stardust.webpages.pl/log/
