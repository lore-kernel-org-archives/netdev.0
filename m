From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bug 1597] New: kernel BUG at mm/slab.c:1708!
Date: Tue, 25 Nov 2003 14:35:37 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031125143537.7b446ff2.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shal@free.fr
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Beats me.  Networking skb refcounting problem perhaps?

Begin forwarded message:

Date: Tue, 25 Nov 2003 14:27:34 -0800
From: bugme-daemon@osdl.org
To: akpm@digeo.com
Subject: [Bug 1597] New: kernel BUG at mm/slab.c:1708!


http://bugme.osdl.org/show_bug.cgi?id=1597

           Summary: kernel BUG at mm/slab.c:1708!
    Kernel Version: kernel-2.6.0-test9-mm5
            Status: NEW
          Severity: normal
             Owner: akpm@digeo.com
         Submitter: shal@free.fr


Distribution: slackware-current
Hardware Environment: Athlon XP1600+  via KT333 mother card
Software Environment:
grep -v "not set" .config | grep CONFIG : 
CONFIG_X86=y
CONFIG_MMU=y
CONFIG_UID16=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_EXPERIMENTAL=y
CONFIG_CLEAN_COMPILE=y
CONFIG_BROKEN_ON_SMP=y
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
CONFIG_SYSCTL=y
CONFIG_LOG_BUF_SHIFT=14
CONFIG_KALLSYMS=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_AS=y
CONFIG_IOSCHED_DEADLINE=y
CONFIG_IOSCHED_CFQ=y
CONFIG_MODULES=y
CONFIG_MODULE_UNLOAD=y
CONFIG_OBSOLETE_MODPARM=y
CONFIG_KMOD=y
CONFIG_X86_PC=y
CONFIG_MK7=y
CONFIG_X86_CMPXCHG=y
CONFIG_X86_XADD=y
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_X86_WP_WORKS_OK=y
CONFIG_X86_INVLPG=y
CONFIG_X86_BSWAP=y
CONFIG_X86_POPAD_OK=y
CONFIG_X86_GOOD_APIC=y
CONFIG_X86_INTEL_USERCOPY=y
CONFIG_X86_USE_PPRO_CHECKSUM=y
CONFIG_X86_USE_3DNOW=y
CONFIG_X86_TSC=y
CONFIG_X86_MCE=y
CONFIG_X86_MCE_NONFATAL=y
CONFIG_NOHIGHMEM=y
CONFIG_MTRR=y
CONFIG_PM=y
CONFIG_ACPI=y
CONFIG_ACPI_BOOT=y
CONFIG_ACPI_INTERPRETER=y
CONFIG_ACPI_SLEEP=y
CONFIG_ACPI_SLEEP_PROC_FS=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_FAN=y
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_BUS=y
CONFIG_ACPI_EC=y
CONFIG_ACPI_POWER=y
CONFIG_ACPI_PCI=y
CONFIG_ACPI_SYSTEM=y
CONFIG_PCI=y
CONFIG_PCI_GOANY=y
CONFIG_PCI_BIOS=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_LEGACY_PROC=y
CONFIG_PCI_NAMES=y
CONFIG_HOTPLUG=y
CONFIG_BINFMT_ELF=y
CONFIG_BINFMT_AOUT=y
CONFIG_BINFMT_MISC=y
CONFIG_PNP=y
CONFIG_BLK_DEV_FD=y
CONFIG_BLK_DEV_LOOP=m
CONFIG_BLK_DEV_CRYPTOLOOP=m
CONFIG_BLK_DEV_NBD=m
CONFIG_LBD=y
CONFIG_IDE=y
CONFIG_BLK_DEV_IDE=y
CONFIG_BLK_DEV_IDEDISK=y
CONFIG_IDEDISK_MULTI_MODE=y
CONFIG_BLK_DEV_IDECD=y
CONFIG_IDE_TASKFILE_IO=y
CONFIG_BLK_DEV_IDEPCI=y
CONFIG_IDEPCI_SHARE_IRQ=y
CONFIG_BLK_DEV_IDEDMA_PCI=y
CONFIG_IDEDMA_PCI_AUTO=y
CONFIG_BLK_DEV_ADMA=y
CONFIG_BLK_DEV_PIIX=y
CONFIG_BLK_DEV_VIA82CXXX=m
CONFIG_BLK_DEV_IDEDMA=y
CONFIG_IDEDMA_AUTO=y
CONFIG_SCSI=y
CONFIG_SCSI_PROC_FS=y
CONFIG_BLK_DEV_SD=m
CONFIG_MAX_SD_DISKS=256
CONFIG_BLK_DEV_SR=m
CONFIG_CHR_DEV_SG=m
CONFIG_SCSI_SYM53C8XX_2=m
CONFIG_SCSI_SYM53C8XX_DMA_ADDRESSING_MODE=1
CONFIG_SCSI_SYM53C8XX_DEFAULT_TAGS=16
CONFIG_SCSI_SYM53C8XX_MAX_TAGS=64
CONFIG_NET=y
CONFIG_PACKET=y
CONFIG_UNIX=y
CONFIG_NET_KEY=m
CONFIG_INET=y
CONFIG_IP_MULTICAST=y
CONFIG_NET_IPIP=m
CONFIG_NET_IPGRE=m
CONFIG_INET_AH=m
CONFIG_INET_ESP=m
CONFIG_INET_IPCOMP=m
CONFIG_XFRM=y
CONFIG_XFRM_USER=m
CONFIG_IPV6_SCTP__=y
CONFIG_NETDEVICES=y
CONFIG_DUMMY=m
CONFIG_TUN=m
CONFIG_NET_ETHERNET=y
CONFIG_MII=m
CONFIG_NET_PCI=y
CONFIG_8139TOO=m
CONFIG_PHONE=m
CONFIG_PHONE_IXJ=m
CONFIG_INPUT=y
CONFIG_INPUT_MOUSEDEV=y
CONFIG_INPUT_MOUSEDEV_PSAUX=y
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
CONFIG_SOUND_GAMEPORT=y
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_INPUT_KEYBOARD=y
CONFIG_KEYBOARD_ATKBD=y
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_VT=y
CONFIG_VT_CONSOLE=y
CONFIG_HW_CONSOLE=y
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_CORE=y
CONFIG_UNIX98_PTYS=y
CONFIG_UNIX98_PTY_COUNT=256
CONFIG_I2C=m
CONFIG_I2C_CHARDEV=m
CONFIG_I2C_ALGOBIT=m
CONFIG_RTC=m
CONFIG_DRM=y
CONFIG_DRM_TDFX=m
CONFIG_VIDEO_DEV=m
CONFIG_VIDEO_BT848=m
CONFIG_VIDEO_TUNER=m
CONFIG_VIDEO_BUF=m
CONFIG_VIDEO_BTCX=m
CONFIG_FB=y
CONFIG_FB_3DFX=m
CONFIG_VGA_CONSOLE=y
CONFIG_DUMMY_CONSOLE=y
CONFIG_SOUND=y
CONFIG_SND=y
CONFIG_SND_SEQUENCER=y
CONFIG_SND_OSSEMUL=y
CONFIG_SND_MIXER_OSS=y
CONFIG_SND_PCM_OSS=y
CONFIG_SND_ENS1371=m
CONFIG_SND_USB_AUDIO=m
CONFIG_USB=y
CONFIG_USB_DEVICEFS=y
CONFIG_USB_EHCI_HCD=y
CONFIG_USB_UHCI_HCD=y
CONFIG_USB_AUDIO=m
CONFIG_USB_STORAGE=y
CONFIG_USB_HID=y
CONFIG_USB_HIDINPUT=y
CONFIG_USB_PWC=m
CONFIG_EXT2_FS=y
CONFIG_EXT3_FS=y
CONFIG_EXT3_FS_XATTR=y
CONFIG_JBD=y
CONFIG_FS_MBCACHE=y
CONFIG_AUTOFS4_FS=y
CONFIG_ISO9660_FS=y
CONFIG_JOLIET=y
CONFIG_UDF_FS=y
CONFIG_FAT_FS=y
CONFIG_MSDOS_FS=y
CONFIG_VFAT_FS=y
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
CONFIG_DEVPTS_FS=y
CONFIG_TMPFS=y
CONFIG_RAMFS=y
CONFIG_MSDOS_PARTITION=y
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=y
CONFIG_NLS_CODEPAGE_852=y
CONFIG_NLS_ISO8859_1=y
CONFIG_NLS_ISO8859_15=y
CONFIG_NLS_UTF8=y
CONFIG_DEBUG_KERNEL=y
CONFIG_DEBUG_STACKOVERFLOW=y
CONFIG_DEBUG_SLAB=y
CONFIG_DEBUG_IOVIRT=y
CONFIG_MAGIC_SYSRQ=y
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_PAGEALLOC=y
CONFIG_SPINLINE=y
CONFIG_DEBUG_INFO=y
CONFIG_DEBUG_SPINLOCK_SLEEP=y
CONFIG_FRAME_POINTER=y
CONFIG_CRYPTO=y
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_NULL=m
CONFIG_CRYPTO_MD4=m
CONFIG_CRYPTO_MD5=m
CONFIG_CRYPTO_SHA1=m
CONFIG_CRYPTO_DES=m
CONFIG_CRYPTO_AES=m
CONFIG_CRYPTO_DEFLATE=m
CONFIG_CRC32=m
CONFIG_ZLIB_INFLATE=m
CONFIG_ZLIB_DEFLATE=m
CONFIG_X86_BIOS_REBOOT=y
CONFIG_PC=y

For information,a external module is added : the eagle usb modem module.

Problem Description: a Oops is produced, the process is passed on the DW state: 

Nov 23 20:00:07 shal kernel: slab error in cache_free_debugcheck(): cache
`size-2048': double free, or memory outs
ide object was overwritten
Nov 23 20:00:07 shal kernel: Call Trace:
Nov 23 20:00:07 shal kernel:  [<c0153084>] kfree+0x2e4/0x410
Nov 23 20:00:07 shal kernel:  [<c0312f04>] kfree_skbmem+0x14/0x30
Nov 23 20:00:07 shal kernel:  [<c0312f04>] kfree_skbmem+0x14/0x30
Nov 23 20:00:07 shal kernel:  [<c0312f86>] __kfree_skb+0x66/0xd0
Nov 23 20:00:07 shal kernel:  [<c033b4d8>] tcp_recvmsg+0xb18/0xe10
Nov 23 20:00:07 shal kernel:  [<c035f574>] inet_recvmsg+0x54/0x70
Nov 23 20:00:07 shal kernel:  [<c030ecf4>] sock_aio_read+0xc4/0xe0
Nov 23 20:00:07 shal kernel:  [<c0170212>] do_sync_read+0xc2/0x100
Nov 23 20:00:07 shal kernel:  [<c014c5d2>] __get_free_pages+0x22/0x50
Nov 23 20:00:07 shal kernel:  [<c0122c20>] autoremove_wake_function+0x0/0x50
Nov 23 20:00:07 shal kernel:  [<c0188d1a>] poll_freewait+0x3a/0x50
Nov 23 20:00:07 shal kernel:  [<c0170331>] vfs_read+0xe1/0x120
Nov 23 20:00:07 shal kernel:  [<c01705cf>] sys_read+0x3f/0x60
Nov 23 20:00:07 shal kernel:  [<c03793ff>] syscall_call+0x7/0xb
Nov 23 20:00:07 shal kernel: 
Nov 23 20:00:07 shal kernel: c19c301e: redzone 1: 0x5a5a5a5a, redzone 2: 0xe09e0002.
Nov 23 20:00:07 shal kernel: ------------[ cut here ]------------
Nov 23 20:00:07 shal kernel: kernel BUG at mm/slab.c:1708!
Nov 23 20:00:07 shal kernel: invalid operand: 0000 [#1]
Nov 23 20:00:07 shal kernel: DEBUG_PAGEALLOC
Nov 23 20:00:07 shal kernel: CPU:    0
Nov 23 20:00:07 shal kernel: EIP:    0060:[<c015301b>]    Not tainted VLI
Nov 23 20:00:07 shal kernel: EFLAGS: 00010006
Nov 23 20:00:07 shal kernel: EIP is at kfree+0x27b/0x410
Nov 23 20:00:07 shal kernel: eax: c19c3000   ebx: 80010c00   ecx: 00001000  
edx: 0000001e
Nov 23 20:00:07 shal kernel: esi: cffefb00   edi: c19c3000   ebp: c3f99d84  
esp: c3f99d54
Nov 23 20:00:07 shal kernel: ds: 007b   es: 007b   ss: 0068
Nov 23 20:00:07 shal kernel: Process mlnet (pid: 777, threadinfo=c3f98000
task=cc07b950)
Nov 23 20:00:07 shal kernel: Stack: cffefb00 c19c301e 5a5a5a5a e09e0002 019c301e
c0312f04 c19c301e cffe8f78 
Nov 23 20:00:07 shal kernel:        00000282 cbfd3f60 00000000 558f8d7b c3f99d98
c0312f04 c19c3816 00000000 
Nov 23 20:00:07 shal kernel:        c91e6f00 c3f99db0 c0312f86 cbfd3f60 cbfd3f60
00000000 cbfd3f60 c3f99e14 
Nov 23 20:00:07 shal kernel: Call Trace:
Nov 23 20:00:07 shal kernel:  [<c0312f04>] kfree_skbmem+0x14/0x30
Nov 23 20:00:07 shal kernel:  [<c0312f04>] kfree_skbmem+0x14/0x30
Nov 23 20:00:07 shal kernel:  [<c0312f86>] __kfree_skb+0x66/0xd0
Nov 23 20:00:07 shal kernel:  [<c033b4d8>] tcp_recvmsg+0xb18/0xe10
Nov 23 20:00:07 shal kernel:  [<c035f574>] inet_recvmsg+0x54/0x70
Nov 23 20:00:07 shal kernel:  [<c030ecf4>] sock_aio_read+0xc4/0xe0
Nov 23 20:00:07 shal kernel:  [<c0170212>] do_sync_read+0xc2/0x100
Nov 23 20:00:07 shal kernel:  [<c014c5d2>] __get_free_pages+0x22/0x50
Nov 23 20:00:07 shal kernel:  [<c0122c20>] autoremove_wake_function+0x0/0x50
Nov 23 20:00:07 shal kernel:  [<c0188d1a>] poll_freewait+0x3a/0x50
Nov 23 20:00:07 shal kernel:  [<c0170331>] vfs_read+0xe1/0x120
Nov 23 20:00:07 shal kernel:  [<c01705cf>] sys_read+0x3f/0x60
Nov 23 20:00:07 shal kernel:  [<c03793ff>] syscall_call+0x7/0xb
Nov 23 20:00:07 shal kernel: 
Nov 23 20:00:07 shal kernel: Code: 8b 5e 38 e9 2b ff ff ff 8b 45 e8 03 86 b8 00
00 00 89 74 24 04 c7 44 24 08 05 00 00 00 89 04 24 ff 56 78 8b 5e 38 e9 f8 fe ff
ff <0f> 0b ac 06 d7 af 38 c0 e9 e2 fe ff ff 0f 0b ab 06 d7 af 38 c0
 



Steps to reproduce:
don't know , but I have it few times.

------- You are receiving this mail because: -------
You are the assignee for the bug, or are watching the assignee.
