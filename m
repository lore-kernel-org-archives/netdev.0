From: Stephen Hemminger <shemminger@osdl.org>
Subject: Fw: [Bug 4279] New: When I try to start vpnc the
 net/core/skbuff.c:91 crash
Date: Thu, 3 Mar 2005 09:58:32 -0800
Message-ID: <20050303095832.6a084856@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: maxk@qualcomm.com, max_mk@yahoo.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Looks like a something wrong with tun driver on 2.6.11
------------------------

http://bugme.osdl.org/show_bug.cgi?id=4279

           Summary: When I try to start vpnc the net/core/skbuff.c:91 crash
    Kernel Version: 2.6.11 vanilla
            Status: NEW
          Severity: blocking
             Owner: shemminger@osdl.org
         Submitter: linuxale@libero.it


Distribution: FC3
Hardware Environment: Acer Travelmate 529Txv
Software Environment: 
Problem Description: When I try to start vpnc the net/core/skbuff.c:91 crash

--------------------------

Mar  3 14:43:05 localhost kernel: kernel BUG at net/core/skbuff.c:91!
Mar  3 14:43:05 localhost kernel: invalid operand: 0000 [#2]
Mar  3 14:43:05 localhost kernel: PREEMPT 
Mar  3 14:43:05 localhost kernel: Modules linked in: tun crc32 serial_cs 8250 se
rial_core psmouse parport_pc lp parport autofs4 af_packet pcmcia ip_conntrack bi
nfmt_misc md5 ipv6 video thermal processor fan button battery ac md usbhid usbmo
use yenta_socket rsrc_nonstatic pcmcia_core ohci_hcd usbcore snd_ali5451 snd_ac9
7_codec snd_pcm snd_timer snd soundcore snd_page_alloc eepro100 mii ide_cd cdrom
 reiserfs dm_mod
Mar  3 14:43:05 localhost kernel: CPU:    0
Mar  3 14:43:05 localhost kernel: EIP:    0060:[<c028ce6b>]    Not tainted VLI
Mar  3 14:43:05 localhost kernel: EFLAGS: 00010286   (2.6.11) 
Mar  3 14:43:05 localhost kernel: EIP is at skb_over_panic+0x3b/0x50
Mar  3 14:43:05 localhost kernel: eax: 0000002e   ebx: c80ed960   ecx: c035780c 
  edx: 00000001
Mar  3 14:43:05 localhost kernel: esi: c084be20   edi: 000000f4   ebp: 000000f4 
  esp: c7b07f1c
Mar  3 14:43:05 localhost kernel: ds: 007b   es: 007b   ss: 0068
Mar  3 14:43:05 localhost kernel: Process vpnc (pid: 19368, threadinfo=c7b06000 
task=d23b45a0)
Mar  3 14:43:05 localhost kernel: Stack: c033b188 d90e747e 000000f4 000000f4 c03
2155c d90e748a c80ed960 000000f4 
Mar  3 14:43:05 localhost kernel:        d90e747e cb47d902 00080000 00000000 000
000f4 d57301a0 08057684 d90e74e8 
Mar  3 14:43:05 localhost kernel:        d57301a0 c7b07f6c 00000001 c7b07fac 080
57684 000000f4 c015da95 d57301a0 
Mar  3 14:43:05 localhost kernel: Call Trace:
Mar  3 14:43:05 localhost kernel:  [<d90e747e>] tun_chr_writev+0x15e/0x190 [tun]
Mar  3 14:43:05 localhost kernel:  [<d90e748a>] tun_chr_writev+0x16a/0x190 [tun]
Mar  3 14:43:05 localhost kernel:  [<d90e747e>] tun_chr_writev+0x15e/0x190 [tun]
Mar  3 14:43:05 localhost kernel:  [<d90e74e8>] tun_chr_write+0x38/0x40 [tun]
Mar  3 14:43:05 localhost kernel:  [<c015da95>] vfs_write+0x155/0x160
Mar  3 14:43:05 localhost kernel:  [<c015db71>] sys_write+0x51/0x80
Mar  3 14:43:05 localhost kernel:  [<c0103239>] sysenter_past_esp+0x52/0x75
Mar  3 14:43:05 localhost kernel: Code: c0 0f 44 c2 89 44 24 10 8b 44 24 1c 89 4
4 24 0c 8b 41 60 c7 04 24 88 b1 33 c0 89 44 24 08 8b 44 24 20 89 44 24 04 e8 e5 
d7 e8 ff <0f> 0b 5b 00 13 8b 33 c0 83 c4 14 c3 89 f6 8d bc 27 00 00 00 00 
