From: =?ISO-8859-15?Q?Fran=E7ois_Valenduc?=
	<francois.valenduc-bmtTS95sd5BUM80lpFwj4w@public.gmane.org>
Subject: Re: [Bugme-new] [Bug 11144] New: dhcp doesn't work with iwl4965
Date: Wed, 23 Jul 2008 14:36:37 +0200
Message-ID: <488725D5.8030900@tvcablenet.be>
References: <bug-11144-10286@http.bugzilla.kernel.org/>	<20080722034850.dbbc5566.akpm@linux-foundation.org>	<4886E49D.6010700@tvcablenet.be> <20080723010522.389a948f.akpm@linux-foundation.org> <4886F727.6010301@tvcablenet.be> <48870425.50908@trash.net> <48871632.3010205@tvcablenet.be> <4887169B.6090102@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070907010302060305020807"
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4887169B.6090102-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070907010302060305020807
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 8bit

Patrick McHardy a écrit :
> François Valenduc wrote:
>> Patrick McHardy a écrit :
>>> François Valenduc wrote:
>>>> OK, thanks for the explanation. But do you have more ideas about 
>>>> the problem ?
>>>
>>> I tested myself using dhcpcd 3.2.3 on an ethernet device and it
>>> works fine, so this appears to be driver related.
>>>
>>>
>>
>> I also noticed that DHCP works without problem with my ethernet card 
>> (using the sky2 driver), so there seems to be a problem or conflict 
>> with the iwl4965 driver. However, if I use dhclient instead of 
>> dhcpcd, I can get an IP adress with DHCP and the DNS servers are 
>> correctly written in /etc/resolv.conf. Unfortunately, name resolution 
>> doesn't work, even if I can ping the DNS server.
>
> Interesting. Could you post straces of both commands please?
>
>
>
>
I also send the output of strace for dhcpd under kernel 2.6.26 (where it 
works correctly).
François

--------------070907010302060305020807
Content-Type: text/plain;
 name="strace-dhcpcd-ok"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="strace-dhcpcd-ok"

execve("/sbin/dhcpcd", ["dhcpcd", "-h", "pc-francois", "-m", "2000", "wlan0"], [/* 74 vars */]) = 0
brk(0)                                  = 0x956000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fdcb2554000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fdcb2553000
access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/opengl/nvidia/lib/tls/x86_64/librt.so.1", O_RDONLY) = -1 ENOENT (No such file or directory)
stat("/usr/lib/opengl/nvidia/lib/tls/x86_64", 0x7fffba552980) = -1 ENOENT (No such file or directory)
open("/usr/lib/opengl/nvidia/lib/tls/librt.so.1", O_RDONLY) = -1 ENOENT (No such file or directory)
stat("/usr/lib/opengl/nvidia/lib/tls", 0x7fffba552980) = -1 ENOENT (No such file or directory)
open("/usr/lib/opengl/nvidia/lib/x86_64/librt.so.1", O_RDONLY) = -1 ENOENT (No such file or directory)
stat("/usr/lib/opengl/nvidia/lib/x86_64", 0x7fffba552980) = -1 ENOENT (No such file or directory)
open("/usr/lib/opengl/nvidia/lib/librt.so.1", O_RDONLY) = -1 ENOENT (No such file or directory)
stat("/usr/lib/opengl/nvidia/lib", {st_mode=S_IFDIR|0755, st_size=512, ...}) = 0
open("/etc/ld.so.cache", O_RDONLY)      = 3
fstat(3, {st_mode=S_IFREG|0644, st_size=170161, ...}) = 0
mmap(NULL, 170161, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7fdcb2529000
close(3)                                = 0
open("/lib/librt.so.1", O_RDONLY)       = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\300\"\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_mode=S_IFREG|0755, st_size=35688, ...}) = 0
mmap(NULL, 2132968, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7fdcb2132000
mprotect(0x7fdcb213a000, 2093056, PROT_NONE) = 0
mmap(0x7fdcb2339000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x7000) = 0x7fdcb2339000
close(3)                                = 0
open("/usr/lib/opengl/nvidia/lib/libc.so.6", O_RDONLY) = -1 ENOENT (No such file or directory)
open("/lib/libc.so.6", O_RDONLY)        = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\220\334\1\0\0\0\0\0"..., 832) = 832
fstat(3, {st_mode=S_IFREG|0755, st_size=1293456, ...}) = 0
mmap(NULL, 3399928, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7fdcb1df3000
mprotect(0x7fdcb1f29000, 2093056, PROT_NONE) = 0
mmap(0x7fdcb2128000, 20480, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x135000) = 0x7fdcb2128000
mmap(0x7fdcb212d000, 16632, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7fdcb212d000
close(3)                                = 0
open("/usr/lib/opengl/nvidia/lib/libpthread.so.0", O_RDONLY) = -1 ENOENT (No such file or directory)
open("/lib/libpthread.so.0", O_RDONLY)  = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\240W\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_mode=S_IFREG|0755, st_size=131577, ...}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fdcb2528000
mmap(NULL, 2204528, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7fdcb1bd8000
mprotect(0x7fdcb1bed000, 2097152, PROT_NONE) = 0
mmap(0x7fdcb1ded000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x15000) = 0x7fdcb1ded000
mmap(0x7fdcb1def000, 13168, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7fdcb1def000
close(3)                                = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fdcb2527000
arch_prctl(ARCH_SET_FS, 0x7fdcb25276f0) = 0
mprotect(0x7fdcb1ded000, 4096, PROT_READ) = 0
mprotect(0x7fdcb2128000, 16384, PROT_READ) = 0
mprotect(0x7fdcb2339000, 4096, PROT_READ) = 0
mprotect(0x60e000, 4096, PROT_READ)     = 0
mprotect(0x7fdcb2555000, 4096, PROT_READ) = 0
munmap(0x7fdcb2529000, 170161)          = 0
set_tid_address(0x7fdcb2527780)         = 16589
set_robust_list(0x7fdcb2527790, 0x18)   = 0
rt_sigaction(SIGRTMIN, {0x7fdcb1bdd310, [], SA_RESTORER|SA_SIGINFO, 0x7fdcb1be5ec0}, NULL, 8) = 0
rt_sigaction(SIGRT_1, {0x7fdcb1bdd390, [], SA_RESTORER|SA_RESTART|SA_SIGINFO, 0x7fdcb1be5ec0}, NULL, 8) = 0
rt_sigprocmask(SIG_UNBLOCK, [RTMIN RT_1], NULL, 8) = 0
getrlimit(RLIMIT_STACK, {rlim_cur=8192*1024, rlim_max=RLIM_INFINITY}) = 0
getrlimit(RLIMIT_NOFILE, {rlim_cur=1024, rlim_max=1024}) = 0
close(1023)                             = -1 EBADF (Bad file descriptor)
close(1022)                             = -1 EBADF (Bad file descriptor)
close(1021)                             = -1 EBADF (Bad file descriptor)
close(1020)                             = -1 EBADF (Bad file descriptor)
close(1019)                             = -1 EBADF (Bad file descriptor)
close(1018)                             = -1 EBADF (Bad file descriptor)
close(1017)                             = -1 EBADF (Bad file descriptor)
close(1016)                             = -1 EBADF (Bad file descriptor)
close(1015)                             = -1 EBADF (Bad file descriptor)
close(1014)                             = -1 EBADF (Bad file descriptor)
close(1013)                             = -1 EBADF (Bad file descriptor)
close(1012)                             = -1 EBADF (Bad file descriptor)
close(1011)                             = -1 EBADF (Bad file descriptor)
close(1010)                             = -1 EBADF (Bad file descriptor)
close(1009)                             = -1 EBADF (Bad file descriptor)
close(1008)                             = -1 EBADF (Bad file descriptor)
close(1007)                             = -1 EBADF (Bad file descriptor)
close(1006)                             = -1 EBADF (Bad file descriptor)
close(1005)                             = -1 EBADF (Bad file descriptor)
close(1004)                             = -1 EBADF (Bad file descriptor)
close(1003)                             = -1 EBADF (Bad file descriptor)
close(1002)                             = -1 EBADF (Bad file descriptor)
close(1001)                             = -1 EBADF (Bad file descriptor)
close(1000)                             = -1 EBADF (Bad file descriptor)
close(999)                              = -1 EBADF (Bad file descriptor)
close(998)                              = -1 EBADF (Bad file descriptor)
close(997)                              = -1 EBADF (Bad file descriptor)
close(996)                              = -1 EBADF (Bad file descriptor)
close(995)                              = -1 EBADF (Bad file descriptor)
close(994)                              = -1 EBADF (Bad file descriptor)
close(993)                              = -1 EBADF (Bad file descriptor)
close(992)                              = -1 EBADF (Bad file descriptor)
close(991)                              = -1 EBADF (Bad file descriptor)
close(990)                              = -1 EBADF (Bad file descriptor)
close(989)                              = -1 EBADF (Bad file descriptor)
close(988)                              = -1 EBADF (Bad file descriptor)
close(987)                              = -1 EBADF (Bad file descriptor)
close(986)                              = -1 EBADF (Bad file descriptor)
close(985)                              = -1 EBADF (Bad file descriptor)
close(984)                              = -1 EBADF (Bad file descriptor)
close(983)                              = -1 EBADF (Bad file descriptor)
close(982)                              = -1 EBADF (Bad file descriptor)
close(981)                              = -1 EBADF (Bad file descriptor)
close(980)                              = -1 EBADF (Bad file descriptor)
close(979)                              = -1 EBADF (Bad file descriptor)
close(978)                              = -1 EBADF (Bad file descriptor)
close(977)                              = -1 EBADF (Bad file descriptor)
close(976)                              = -1 EBADF (Bad file descriptor)
close(975)                              = -1 EBADF (Bad file descriptor)
close(974)                              = -1 EBADF (Bad file descriptor)
close(973)                              = -1 EBADF (Bad file descriptor)
close(972)                              = -1 EBADF (Bad file descriptor)
close(971)                              = -1 EBADF (Bad file descriptor)
close(970)                              = -1 EBADF (Bad file descriptor)
close(969)                              = -1 EBADF (Bad file descriptor)
close(968)                              = -1 EBADF (Bad file descriptor)
close(967)                              = -1 EBADF (Bad file descriptor)
close(966)                              = -1 EBADF (Bad file descriptor)
close(965)                              = -1 EBADF (Bad file descriptor)
close(964)                              = -1 EBADF (Bad file descriptor)
close(963)                              = -1 EBADF (Bad file descriptor)
close(962)                              = -1 EBADF (Bad file descriptor)
close(961)                              = -1 EBADF (Bad file descriptor)
close(960)                              = -1 EBADF (Bad file descriptor)
close(959)                              = -1 EBADF (Bad file descriptor)
close(958)                              = -1 EBADF (Bad file descriptor)
close(957)                              = -1 EBADF (Bad file descriptor)
close(956)                              = -1 EBADF (Bad file descriptor)
close(955)                              = -1 EBADF (Bad file descriptor)
close(954)                              = -1 EBADF (Bad file descriptor)
close(953)                              = -1 EBADF (Bad file descriptor)
close(952)                              = -1 EBADF (Bad file descriptor)
close(951)                              = -1 EBADF (Bad file descriptor)
close(950)                              = -1 EBADF (Bad file descriptor)
close(949)                              = -1 EBADF (Bad file descriptor)
close(948)                              = -1 EBADF (Bad file descriptor)
close(947)                              = -1 EBADF (Bad file descriptor)
close(946)                              = -1 EBADF (Bad file descriptor)
close(945)                              = -1 EBADF (Bad file descriptor)
close(944)                              = -1 EBADF (Bad file descriptor)
close(943)                              = -1 EBADF (Bad file descriptor)
close(942)                              = -1 EBADF (Bad file descriptor)
close(941)                              = -1 EBADF (Bad file descriptor)
close(940)                              = -1 EBADF (Bad file descriptor)
close(939)                              = -1 EBADF (Bad file descriptor)
close(938)                              = -1 EBADF (Bad file descriptor)
close(937)                              = -1 EBADF (Bad file descriptor)
close(936)                              = -1 EBADF (Bad file descriptor)
close(935)                              = -1 EBADF (Bad file descriptor)
close(934)                              = -1 EBADF (Bad file descriptor)
close(933)                              = -1 EBADF (Bad file descriptor)
close(932)                              = -1 EBADF (Bad file descriptor)
close(931)                              = -1 EBADF (Bad file descriptor)
close(930)                              = -1 EBADF (Bad file descriptor)
close(929)                              = -1 EBADF (Bad file descriptor)
close(928)                              = -1 EBADF (Bad file descriptor)
close(927)                              = -1 EBADF (Bad file descriptor)
close(926)                              = -1 EBADF (Bad file descriptor)
close(925)                              = -1 EBADF (Bad file descriptor)
close(924)                              = -1 EBADF (Bad file descriptor)
close(923)                              = -1 EBADF (Bad file descriptor)
close(922)                              = -1 EBADF (Bad file descriptor)
close(921)                              = -1 EBADF (Bad file descriptor)
close(920)                              = -1 EBADF (Bad file descriptor)
close(919)                              = -1 EBADF (Bad file descriptor)
close(918)                              = -1 EBADF (Bad file descriptor)
close(917)                              = -1 EBADF (Bad file descriptor)
close(916)                              = -1 EBADF (Bad file descriptor)
close(915)                              = -1 EBADF (Bad file descriptor)
close(914)                              = -1 EBADF (Bad file descriptor)
close(913)                              = -1 EBADF (Bad file descriptor)
close(912)                              = -1 EBADF (Bad file descriptor)
close(911)                              = -1 EBADF (Bad file descriptor)
close(910)                              = -1 EBADF (Bad file descriptor)
close(909)                              = -1 EBADF (Bad file descriptor)
close(908)                              = -1 EBADF (Bad file descriptor)
close(907)                              = -1 EBADF (Bad file descriptor)
close(906)                              = -1 EBADF (Bad file descriptor)
close(905)                              = -1 EBADF (Bad file descriptor)
close(904)                              = -1 EBADF (Bad file descriptor)
close(903)                              = -1 EBADF (Bad file descriptor)
close(902)                              = -1 EBADF (Bad file descriptor)
close(901)                              = -1 EBADF (Bad file descriptor)
close(900)                              = -1 EBADF (Bad file descriptor)
close(899)                              = -1 EBADF (Bad file descriptor)
close(898)                              = -1 EBADF (Bad file descriptor)
close(897)                              = -1 EBADF (Bad file descriptor)
close(896)                              = -1 EBADF (Bad file descriptor)
close(895)                              = -1 EBADF (Bad file descriptor)
close(894)                              = -1 EBADF (Bad file descriptor)
close(893)                              = -1 EBADF (Bad file descriptor)
close(892)                              = -1 EBADF (Bad file descriptor)
close(891)                              = -1 EBADF (Bad file descriptor)
close(890)                              = -1 EBADF (Bad file descriptor)
close(889)                              = -1 EBADF (Bad file descriptor)
close(888)                              = -1 EBADF (Bad file descriptor)
close(887)                              = -1 EBADF (Bad file descriptor)
close(886)                              = -1 EBADF (Bad file descriptor)
close(885)                              = -1 EBADF (Bad file descriptor)
close(884)                              = -1 EBADF (Bad file descriptor)
close(883)                              = -1 EBADF (Bad file descriptor)
close(882)                              = -1 EBADF (Bad file descriptor)
close(881)                              = -1 EBADF (Bad file descriptor)
close(880)                              = -1 EBADF (Bad file descriptor)
close(879)                              = -1 EBADF (Bad file descriptor)
close(878)                              = -1 EBADF (Bad file descriptor)
close(877)                              = -1 EBADF (Bad file descriptor)
close(876)                              = -1 EBADF (Bad file descriptor)
close(875)                              = -1 EBADF (Bad file descriptor)
close(874)                              = -1 EBADF (Bad file descriptor)
close(873)                              = -1 EBADF (Bad file descriptor)
close(872)                              = -1 EBADF (Bad file descriptor)
close(871)                              = -1 EBADF (Bad file descriptor)
close(870)                              = -1 EBADF (Bad file descriptor)
close(869)                              = -1 EBADF (Bad file descriptor)
close(868)                              = -1 EBADF (Bad file descriptor)
close(867)                              = -1 EBADF (Bad file descriptor)
close(866)                              = -1 EBADF (Bad file descriptor)
close(865)                              = -1 EBADF (Bad file descriptor)
close(864)                              = -1 EBADF (Bad file descriptor)
close(863)                              = -1 EBADF (Bad file descriptor)
close(862)                              = -1 EBADF (Bad file descriptor)
close(861)                              = -1 EBADF (Bad file descriptor)
close(860)                              = -1 EBADF (Bad file descriptor)
close(859)                              = -1 EBADF (Bad file descriptor)
close(858)                              = -1 EBADF (Bad file descriptor)
close(857)                              = -1 EBADF (Bad file descriptor)
close(856)                              = -1 EBADF (Bad file descriptor)
close(855)                              = -1 EBADF (Bad file descriptor)
close(854)                              = -1 EBADF (Bad file descriptor)
close(853)                              = -1 EBADF (Bad file descriptor)
close(852)                              = -1 EBADF (Bad file descriptor)
close(851)                              = -1 EBADF (Bad file descriptor)
close(850)                              = -1 EBADF (Bad file descriptor)
close(849)                              = -1 EBADF (Bad file descriptor)
close(848)                              = -1 EBADF (Bad file descriptor)
close(847)                              = -1 EBADF (Bad file descriptor)
close(846)                              = -1 EBADF (Bad file descriptor)
close(845)                              = -1 EBADF (Bad file descriptor)
close(844)                              = -1 EBADF (Bad file descriptor)
close(843)                              = -1 EBADF (Bad file descriptor)
close(842)                              = -1 EBADF (Bad file descriptor)
close(841)                              = -1 EBADF (Bad file descriptor)
close(840)                              = -1 EBADF (Bad file descriptor)
close(839)                              = -1 EBADF (Bad file descriptor)
close(838)                              = -1 EBADF (Bad file descriptor)
close(837)                              = -1 EBADF (Bad file descriptor)
close(836)                              = -1 EBADF (Bad file descriptor)
close(835)                              = -1 EBADF (Bad file descriptor)
close(834)                              = -1 EBADF (Bad file descriptor)
close(833)                              = -1 EBADF (Bad file descriptor)
close(832)                              = -1 EBADF (Bad file descriptor)
close(831)                              = -1 EBADF (Bad file descriptor)
close(830)                              = -1 EBADF (Bad file descriptor)
close(829)                              = -1 EBADF (Bad file descriptor)
close(828)                              = -1 EBADF (Bad file descriptor)
close(827)                              = -1 EBADF (Bad file descriptor)
close(826)                              = -1 EBADF (Bad file descriptor)
close(825)                              = -1 EBADF (Bad file descriptor)
close(824)                              = -1 EBADF (Bad file descriptor)
close(823)                              = -1 EBADF (Bad file descriptor)
close(822)                              = -1 EBADF (Bad file descriptor)
close(821)                              = -1 EBADF (Bad file descriptor)
close(820)                              = -1 EBADF (Bad file descriptor)
close(819)                              = -1 EBADF (Bad file descriptor)
close(818)                              = -1 EBADF (Bad file descriptor)
close(817)                              = -1 EBADF (Bad file descriptor)
close(816)                              = -1 EBADF (Bad file descriptor)
close(815)                              = -1 EBADF (Bad file descriptor)
close(814)                              = -1 EBADF (Bad file descriptor)
close(813)                              = -1 EBADF (Bad file descriptor)
close(812)                              = -1 EBADF (Bad file descriptor)
close(811)                              = -1 EBADF (Bad file descriptor)
close(810)                              = -1 EBADF (Bad file descriptor)
close(809)                              = -1 EBADF (Bad file descriptor)
close(808)                              = -1 EBADF (Bad file descriptor)
close(807)                              = -1 EBADF (Bad file descriptor)
close(806)                              = -1 EBADF (Bad file descriptor)
close(805)                              = -1 EBADF (Bad file descriptor)
close(804)                              = -1 EBADF (Bad file descriptor)
close(803)                              = -1 EBADF (Bad file descriptor)
close(802)                              = -1 EBADF (Bad file descriptor)
close(801)                              = -1 EBADF (Bad file descriptor)
close(800)                              = -1 EBADF (Bad file descriptor)
close(799)                              = -1 EBADF (Bad file descriptor)
close(798)                              = -1 EBADF (Bad file descriptor)
close(797)                              = -1 EBADF (Bad file descriptor)
close(796)                              = -1 EBADF (Bad file descriptor)
close(795)                              = -1 EBADF (Bad file descriptor)
close(794)                              = -1 EBADF (Bad file descriptor)
close(793)                              = -1 EBADF (Bad file descriptor)
close(792)                              = -1 EBADF (Bad file descriptor)
close(791)                              = -1 EBADF (Bad file descriptor)
close(790)                              = -1 EBADF (Bad file descriptor)
close(789)                              = -1 EBADF (Bad file descriptor)
close(788)                              = -1 EBADF (Bad file descriptor)
close(787)                              = -1 EBADF (Bad file descriptor)
close(786)                              = -1 EBADF (Bad file descriptor)
close(785)                              = -1 EBADF (Bad file descriptor)
close(784)                              = -1 EBADF (Bad file descriptor)
close(783)                              = -1 EBADF (Bad file descriptor)
close(782)                              = -1 EBADF (Bad file descriptor)
close(781)                              = -1 EBADF (Bad file descriptor)
close(780)                              = -1 EBADF (Bad file descriptor)
close(779)                              = -1 EBADF (Bad file descriptor)
close(778)                              = -1 EBADF (Bad file descriptor)
close(777)                              = -1 EBADF (Bad file descriptor)
close(776)                              = -1 EBADF (Bad file descriptor)
close(775)                              = -1 EBADF (Bad file descriptor)
close(774)                              = -1 EBADF (Bad file descriptor)
close(773)                              = -1 EBADF (Bad file descriptor)
close(772)                              = -1 EBADF (Bad file descriptor)
close(771)                              = -1 EBADF (Bad file descriptor)
close(770)                              = -1 EBADF (Bad file descriptor)
close(769)                              = -1 EBADF (Bad file descriptor)
close(768)                              = -1 EBADF (Bad file descriptor)
close(767)                              = -1 EBADF (Bad file descriptor)
close(766)                              = -1 EBADF (Bad file descriptor)
close(765)                              = -1 EBADF (Bad file descriptor)
close(764)                              = -1 EBADF (Bad file descriptor)
close(763)                              = -1 EBADF (Bad file descriptor)
close(762)                              = -1 EBADF (Bad file descriptor)
close(761)                              = -1 EBADF (Bad file descriptor)
close(760)                              = -1 EBADF (Bad file descriptor)
close(759)                              = -1 EBADF (Bad file descriptor)
close(758)                              = -1 EBADF (Bad file descriptor)
close(757)                              = -1 EBADF (Bad file descriptor)
close(756)                              = -1 EBADF (Bad file descriptor)
close(755)                              = -1 EBADF (Bad file descriptor)
close(754)                              = -1 EBADF (Bad file descriptor)
close(753)                              = -1 EBADF (Bad file descriptor)
close(752)                              = -1 EBADF (Bad file descriptor)
close(751)                              = -1 EBADF (Bad file descriptor)
close(750)                              = -1 EBADF (Bad file descriptor)
close(749)                              = -1 EBADF (Bad file descriptor)
close(748)                              = -1 EBADF (Bad file descriptor)
close(747)                              = -1 EBADF (Bad file descriptor)
close(746)                              = -1 EBADF (Bad file descriptor)
close(745)                              = -1 EBADF (Bad file descriptor)
close(744)                              = -1 EBADF (Bad file descriptor)
close(743)                              = -1 EBADF (Bad file descriptor)
close(742)                              = -1 EBADF (Bad file descriptor)
close(741)                              = -1 EBADF (Bad file descriptor)
close(740)                              = -1 EBADF (Bad file descriptor)
close(739)                              = -1 EBADF (Bad file descriptor)
close(738)                              = -1 EBADF (Bad file descriptor)
close(737)                              = -1 EBADF (Bad file descriptor)
close(736)                              = -1 EBADF (Bad file descriptor)
close(735)                              = -1 EBADF (Bad file descriptor)
close(734)                              = -1 EBADF (Bad file descriptor)
close(733)                              = -1 EBADF (Bad file descriptor)
close(732)                              = -1 EBADF (Bad file descriptor)
close(731)                              = -1 EBADF (Bad file descriptor)
close(730)                              = -1 EBADF (Bad file descriptor)
close(729)                              = -1 EBADF (Bad file descriptor)
close(728)                              = -1 EBADF (Bad file descriptor)
close(727)                              = -1 EBADF (Bad file descriptor)
close(726)                              = -1 EBADF (Bad file descriptor)
close(725)                              = -1 EBADF (Bad file descriptor)
close(724)                              = -1 EBADF (Bad file descriptor)
close(723)                              = -1 EBADF (Bad file descriptor)
close(722)                              = -1 EBADF (Bad file descriptor)
close(721)                              = -1 EBADF (Bad file descriptor)
close(720)                              = -1 EBADF (Bad file descriptor)
close(719)                              = -1 EBADF (Bad file descriptor)
close(718)                              = -1 EBADF (Bad file descriptor)
close(717)                              = -1 EBADF (Bad file descriptor)
close(716)                              = -1 EBADF (Bad file descriptor)
close(715)                              = -1 EBADF (Bad file descriptor)
close(714)                              = -1 EBADF (Bad file descriptor)
close(713)                              = -1 EBADF (Bad file descriptor)
close(712)                              = -1 EBADF (Bad file descriptor)
close(711)                              = -1 EBADF (Bad file descriptor)
close(710)                              = -1 EBADF (Bad file descriptor)
close(709)                              = -1 EBADF (Bad file descriptor)
close(708)                              = -1 EBADF (Bad file descriptor)
close(707)                              = -1 EBADF (Bad file descriptor)
close(706)                              = -1 EBADF (Bad file descriptor)
close(705)                              = -1 EBADF (Bad file descriptor)
close(704)                              = -1 EBADF (Bad file descriptor)
close(703)                              = -1 EBADF (Bad file descriptor)
close(702)                              = -1 EBADF (Bad file descriptor)
close(701)                              = -1 EBADF (Bad file descriptor)
close(700)                              = -1 EBADF (Bad file descriptor)
close(699)                              = -1 EBADF (Bad file descriptor)
close(698)                              = -1 EBADF (Bad file descriptor)
close(697)                              = -1 EBADF (Bad file descriptor)
close(696)                              = -1 EBADF (Bad file descriptor)
close(695)                              = -1 EBADF (Bad file descriptor)
close(694)                              = -1 EBADF (Bad file descriptor)
close(693)                              = -1 EBADF (Bad file descriptor)
close(692)                              = -1 EBADF (Bad file descriptor)
close(691)                              = -1 EBADF (Bad file descriptor)
close(690)                              = -1 EBADF (Bad file descriptor)
close(689)                              = -1 EBADF (Bad file descriptor)
close(688)                              = -1 EBADF (Bad file descriptor)
close(687)                              = -1 EBADF (Bad file descriptor)
close(686)                              = -1 EBADF (Bad file descriptor)
close(685)                              = -1 EBADF (Bad file descriptor)
close(684)                              = -1 EBADF (Bad file descriptor)
close(683)                              = -1 EBADF (Bad file descriptor)
close(682)                              = -1 EBADF (Bad file descriptor)
close(681)                              = -1 EBADF (Bad file descriptor)
close(680)                              = -1 EBADF (Bad file descriptor)
close(679)                              = -1 EBADF (Bad file descriptor)
close(678)                              = -1 EBADF (Bad file descriptor)
close(677)                              = -1 EBADF (Bad file descriptor)
close(676)                              = -1 EBADF (Bad file descriptor)
close(675)                              = -1 EBADF (Bad file descriptor)
close(674)                              = -1 EBADF (Bad file descriptor)
close(673)                              = -1 EBADF (Bad file descriptor)
close(672)                              = -1 EBADF (Bad file descriptor)
close(671)                              = -1 EBADF (Bad file descriptor)
close(670)                              = -1 EBADF (Bad file descriptor)
close(669)                              = -1 EBADF (Bad file descriptor)
close(668)                              = -1 EBADF (Bad file descriptor)
close(667)                              = -1 EBADF (Bad file descriptor)
close(666)                              = -1 EBADF (Bad file descriptor)
close(665)                              = -1 EBADF (Bad file descriptor)
close(664)                              = -1 EBADF (Bad file descriptor)
close(663)                              = -1 EBADF (Bad file descriptor)
close(662)                              = -1 EBADF (Bad file descriptor)
close(661)                              = -1 EBADF (Bad file descriptor)
close(660)                              = -1 EBADF (Bad file descriptor)
close(659)                              = -1 EBADF (Bad file descriptor)
close(658)                              = -1 EBADF (Bad file descriptor)
close(657)                              = -1 EBADF (Bad file descriptor)
close(656)                              = -1 EBADF (Bad file descriptor)
close(655)                              = -1 EBADF (Bad file descriptor)
close(654)                              = -1 EBADF (Bad file descriptor)
close(653)                              = -1 EBADF (Bad file descriptor)
close(652)                              = -1 EBADF (Bad file descriptor)
close(651)                              = -1 EBADF (Bad file descriptor)
close(650)                              = -1 EBADF (Bad file descriptor)
close(649)                              = -1 EBADF (Bad file descriptor)
close(648)                              = -1 EBADF (Bad file descriptor)
close(647)                              = -1 EBADF (Bad file descriptor)
close(646)                              = -1 EBADF (Bad file descriptor)
close(645)                              = -1 EBADF (Bad file descriptor)
close(644)                              = -1 EBADF (Bad file descriptor)
close(643)                              = -1 EBADF (Bad file descriptor)
close(642)                              = -1 EBADF (Bad file descriptor)
close(641)                              = -1 EBADF (Bad file descriptor)
close(640)                              = -1 EBADF (Bad file descriptor)
close(639)                              = -1 EBADF (Bad file descriptor)
close(638)                              = -1 EBADF (Bad file descriptor)
close(637)                              = -1 EBADF (Bad file descriptor)
close(636)                              = -1 EBADF (Bad file descriptor)
close(635)                              = -1 EBADF (Bad file descriptor)
close(634)                              = -1 EBADF (Bad file descriptor)
close(633)                              = -1 EBADF (Bad file descriptor)
close(632)                              = -1 EBADF (Bad file descriptor)
close(631)                              = -1 EBADF (Bad file descriptor)
close(630)                              = -1 EBADF (Bad file descriptor)
close(629)                              = -1 EBADF (Bad file descriptor)
close(628)                              = -1 EBADF (Bad file descriptor)
close(627)                              = -1 EBADF (Bad file descriptor)
close(626)                              = -1 EBADF (Bad file descriptor)
close(625)                              = -1 EBADF (Bad file descriptor)
close(624)                              = -1 EBADF (Bad file descriptor)
close(623)                              = -1 EBADF (Bad file descriptor)
close(622)                              = -1 EBADF (Bad file descriptor)
close(621)                              = -1 EBADF (Bad file descriptor)
close(620)                              = -1 EBADF (Bad file descriptor)
close(619)                              = -1 EBADF (Bad file descriptor)
close(618)                              = -1 EBADF (Bad file descriptor)
close(617)                              = -1 EBADF (Bad file descriptor)
close(616)                              = -1 EBADF (Bad file descriptor)
close(615)                              = -1 EBADF (Bad file descriptor)
close(614)                              = -1 EBADF (Bad file descriptor)
close(613)                              = -1 EBADF (Bad file descriptor)
close(612)                              = -1 EBADF (Bad file descriptor)
close(611)                              = -1 EBADF (Bad file descriptor)
close(610)                              = -1 EBADF (Bad file descriptor)
close(609)                              = -1 EBADF (Bad file descriptor)
close(608)                              = -1 EBADF (Bad file descriptor)
close(607)                              = -1 EBADF (Bad file descriptor)
close(606)                              = -1 EBADF (Bad file descriptor)
close(605)                              = -1 EBADF (Bad file descriptor)
close(604)                              = -1 EBADF (Bad file descriptor)
close(603)                              = -1 EBADF (Bad file descriptor)
close(602)                              = -1 EBADF (Bad file descriptor)
close(601)                              = -1 EBADF (Bad file descriptor)
close(600)                              = -1 EBADF (Bad file descriptor)
close(599)                              = -1 EBADF (Bad file descriptor)
close(598)                              = -1 EBADF (Bad file descriptor)
close(597)                              = -1 EBADF (Bad file descriptor)
close(596)                              = -1 EBADF (Bad file descriptor)
close(595)                              = -1 EBADF (Bad file descriptor)
close(594)                              = -1 EBADF (Bad file descriptor)
close(593)                              = -1 EBADF (Bad file descriptor)
close(592)                              = -1 EBADF (Bad file descriptor)
close(591)                              = -1 EBADF (Bad file descriptor)
close(590)                              = -1 EBADF (Bad file descriptor)
close(589)                              = -1 EBADF (Bad file descriptor)
close(588)                              = -1 EBADF (Bad file descriptor)
close(587)                              = -1 EBADF (Bad file descriptor)
close(586)                              = -1 EBADF (Bad file descriptor)
close(585)                              = -1 EBADF (Bad file descriptor)
close(584)                              = -1 EBADF (Bad file descriptor)
close(583)                              = -1 EBADF (Bad file descriptor)
close(582)                              = -1 EBADF (Bad file descriptor)
close(581)                              = -1 EBADF (Bad file descriptor)
close(580)                              = -1 EBADF (Bad file descriptor)
close(579)                              = -1 EBADF (Bad file descriptor)
close(578)                              = -1 EBADF (Bad file descriptor)
close(577)                              = -1 EBADF (Bad file descriptor)
close(576)                              = -1 EBADF (Bad file descriptor)
close(575)                              = -1 EBADF (Bad file descriptor)
close(574)                              = -1 EBADF (Bad file descriptor)
close(573)                              = -1 EBADF (Bad file descriptor)
close(572)                              = -1 EBADF (Bad file descriptor)
close(571)                              = -1 EBADF (Bad file descriptor)
close(570)                              = -1 EBADF (Bad file descriptor)
close(569)                              = -1 EBADF (Bad file descriptor)
close(568)                              = -1 EBADF (Bad file descriptor)
close(567)                              = -1 EBADF (Bad file descriptor)
close(566)                              = -1 EBADF (Bad file descriptor)
close(565)                              = -1 EBADF (Bad file descriptor)
close(564)                              = -1 EBADF (Bad file descriptor)
close(563)                              = -1 EBADF (Bad file descriptor)
close(562)                              = -1 EBADF (Bad file descriptor)
close(561)                              = -1 EBADF (Bad file descriptor)
close(560)                              = -1 EBADF (Bad file descriptor)
close(559)                              = -1 EBADF (Bad file descriptor)
close(558)                              = -1 EBADF (Bad file descriptor)
close(557)                              = -1 EBADF (Bad file descriptor)
close(556)                              = -1 EBADF (Bad file descriptor)
close(555)                              = -1 EBADF (Bad file descriptor)
close(554)                              = -1 EBADF (Bad file descriptor)
close(553)                              = -1 EBADF (Bad file descriptor)
close(552)                              = -1 EBADF (Bad file descriptor)
close(551)                              = -1 EBADF (Bad file descriptor)
close(550)                              = -1 EBADF (Bad file descriptor)
close(549)                              = -1 EBADF (Bad file descriptor)
close(548)                              = -1 EBADF (Bad file descriptor)
close(547)                              = -1 EBADF (Bad file descriptor)
close(546)                              = -1 EBADF (Bad file descriptor)
close(545)                              = -1 EBADF (Bad file descriptor)
close(544)                              = -1 EBADF (Bad file descriptor)
close(543)                              = -1 EBADF (Bad file descriptor)
close(542)                              = -1 EBADF (Bad file descriptor)
close(541)                              = -1 EBADF (Bad file descriptor)
close(540)                              = -1 EBADF (Bad file descriptor)
close(539)                              = -1 EBADF (Bad file descriptor)
close(538)                              = -1 EBADF (Bad file descriptor)
close(537)                              = -1 EBADF (Bad file descriptor)
close(536)                              = -1 EBADF (Bad file descriptor)
close(535)                              = -1 EBADF (Bad file descriptor)
close(534)                              = -1 EBADF (Bad file descriptor)
close(533)                              = -1 EBADF (Bad file descriptor)
close(532)                              = -1 EBADF (Bad file descriptor)
close(531)                              = -1 EBADF (Bad file descriptor)
close(530)                              = -1 EBADF (Bad file descriptor)
close(529)                              = -1 EBADF (Bad file descriptor)
close(528)                              = -1 EBADF (Bad file descriptor)
close(527)                              = -1 EBADF (Bad file descriptor)
close(526)                              = -1 EBADF (Bad file descriptor)
close(525)                              = -1 EBADF (Bad file descriptor)
close(524)                              = -1 EBADF (Bad file descriptor)
close(523)                              = -1 EBADF (Bad file descriptor)
close(522)                              = -1 EBADF (Bad file descriptor)
close(521)                              = -1 EBADF (Bad file descriptor)
close(520)                              = -1 EBADF (Bad file descriptor)
close(519)                              = -1 EBADF (Bad file descriptor)
close(518)                              = -1 EBADF (Bad file descriptor)
close(517)                              = -1 EBADF (Bad file descriptor)
close(516)                              = -1 EBADF (Bad file descriptor)
close(515)                              = -1 EBADF (Bad file descriptor)
close(514)                              = -1 EBADF (Bad file descriptor)
close(513)                              = -1 EBADF (Bad file descriptor)
close(512)                              = -1 EBADF (Bad file descriptor)
close(511)                              = -1 EBADF (Bad file descriptor)
close(510)                              = -1 EBADF (Bad file descriptor)
close(509)                              = -1 EBADF (Bad file descriptor)
close(508)                              = -1 EBADF (Bad file descriptor)
close(507)                              = -1 EBADF (Bad file descriptor)
close(506)                              = -1 EBADF (Bad file descriptor)
close(505)                              = -1 EBADF (Bad file descriptor)
close(504)                              = -1 EBADF (Bad file descriptor)
close(503)                              = -1 EBADF (Bad file descriptor)
close(502)                              = -1 EBADF (Bad file descriptor)
close(501)                              = -1 EBADF (Bad file descriptor)
close(500)                              = -1 EBADF (Bad file descriptor)
close(499)                              = -1 EBADF (Bad file descriptor)
close(498)                              = -1 EBADF (Bad file descriptor)
close(497)                              = -1 EBADF (Bad file descriptor)
close(496)                              = -1 EBADF (Bad file descriptor)
close(495)                              = -1 EBADF (Bad file descriptor)
close(494)                              = -1 EBADF (Bad file descriptor)
close(493)                              = -1 EBADF (Bad file descriptor)
close(492)                              = -1 EBADF (Bad file descriptor)
close(491)                              = -1 EBADF (Bad file descriptor)
close(490)                              = -1 EBADF (Bad file descriptor)
close(489)                              = -1 EBADF (Bad file descriptor)
close(488)                              = -1 EBADF (Bad file descriptor)
close(487)                              = -1 EBADF (Bad file descriptor)
close(486)                              = -1 EBADF (Bad file descriptor)
close(485)                              = -1 EBADF (Bad file descriptor)
close(484)                              = -1 EBADF (Bad file descriptor)
close(483)                              = -1 EBADF (Bad file descriptor)
close(482)                              = -1 EBADF (Bad file descriptor)
close(481)                              = -1 EBADF (Bad file descriptor)
close(480)                              = -1 EBADF (Bad file descriptor)
close(479)                              = -1 EBADF (Bad file descriptor)
close(478)                              = -1 EBADF (Bad file descriptor)
close(477)                              = -1 EBADF (Bad file descriptor)
close(476)                              = -1 EBADF (Bad file descriptor)
close(475)                              = -1 EBADF (Bad file descriptor)
close(474)                              = -1 EBADF (Bad file descriptor)
close(473)                              = -1 EBADF (Bad file descriptor)
close(472)                              = -1 EBADF (Bad file descriptor)
close(471)                              = -1 EBADF (Bad file descriptor)
close(470)                              = -1 EBADF (Bad file descriptor)
close(469)                              = -1 EBADF (Bad file descriptor)
close(468)                              = -1 EBADF (Bad file descriptor)
close(467)                              = -1 EBADF (Bad file descriptor)
close(466)                              = -1 EBADF (Bad file descriptor)
close(465)                              = -1 EBADF (Bad file descriptor)
close(464)                              = -1 EBADF (Bad file descriptor)
close(463)                              = -1 EBADF (Bad file descriptor)
close(462)                              = -1 EBADF (Bad file descriptor)
close(461)                              = -1 EBADF (Bad file descriptor)
close(460)                              = -1 EBADF (Bad file descriptor)
close(459)                              = -1 EBADF (Bad file descriptor)
close(458)                              = -1 EBADF (Bad file descriptor)
close(457)                              = -1 EBADF (Bad file descriptor)
close(456)                              = -1 EBADF (Bad file descriptor)
close(455)                              = -1 EBADF (Bad file descriptor)
close(454)                              = -1 EBADF (Bad file descriptor)
close(453)                              = -1 EBADF (Bad file descriptor)
close(452)                              = -1 EBADF (Bad file descriptor)
close(451)                              = -1 EBADF (Bad file descriptor)
close(450)                              = -1 EBADF (Bad file descriptor)
close(449)                              = -1 EBADF (Bad file descriptor)
close(448)                              = -1 EBADF (Bad file descriptor)
close(447)                              = -1 EBADF (Bad file descriptor)
close(446)                              = -1 EBADF (Bad file descriptor)
close(445)                              = -1 EBADF (Bad file descriptor)
close(444)                              = -1 EBADF (Bad file descriptor)
close(443)                              = -1 EBADF (Bad file descriptor)
close(442)                              = -1 EBADF (Bad file descriptor)
close(441)                              = -1 EBADF (Bad file descriptor)
close(440)                              = -1 EBADF (Bad file descriptor)
close(439)                              = -1 EBADF (Bad file descriptor)
close(438)                              = -1 EBADF (Bad file descriptor)
close(437)                              = -1 EBADF (Bad file descriptor)
close(436)                              = -1 EBADF (Bad file descriptor)
close(435)                              = -1 EBADF (Bad file descriptor)
close(434)                              = -1 EBADF (Bad file descriptor)
close(433)                              = -1 EBADF (Bad file descriptor)
close(432)                              = -1 EBADF (Bad file descriptor)
close(431)                              = -1 EBADF (Bad file descriptor)
close(430)                              = -1 EBADF (Bad file descriptor)
close(429)                              = -1 EBADF (Bad file descriptor)
close(428)                              = -1 EBADF (Bad file descriptor)
close(427)                              = -1 EBADF (Bad file descriptor)
close(426)                              = -1 EBADF (Bad file descriptor)
close(425)                              = -1 EBADF (Bad file descriptor)
close(424)                              = -1 EBADF (Bad file descriptor)
close(423)                              = -1 EBADF (Bad file descriptor)
close(422)                              = -1 EBADF (Bad file descriptor)
close(421)                              = -1 EBADF (Bad file descriptor)
close(420)                              = -1 EBADF (Bad file descriptor)
close(419)                              = -1 EBADF (Bad file descriptor)
close(418)                              = -1 EBADF (Bad file descriptor)
close(417)                              = -1 EBADF (Bad file descriptor)
close(416)                              = -1 EBADF (Bad file descriptor)
close(415)                              = -1 EBADF (Bad file descriptor)
close(414)                              = -1 EBADF (Bad file descriptor)
close(413)                              = -1 EBADF (Bad file descriptor)
close(412)                              = -1 EBADF (Bad file descriptor)
close(411)                              = -1 EBADF (Bad file descriptor)
close(410)                              = -1 EBADF (Bad file descriptor)
close(409)                              = -1 EBADF (Bad file descriptor)
close(408)                              = -1 EBADF (Bad file descriptor)
close(407)                              = -1 EBADF (Bad file descriptor)
close(406)                              = -1 EBADF (Bad file descriptor)
close(405)                              = -1 EBADF (Bad file descriptor)
close(404)                              = -1 EBADF (Bad file descriptor)
close(403)                              = -1 EBADF (Bad file descriptor)
close(402)                              = -1 EBADF (Bad file descriptor)
close(401)                              = -1 EBADF (Bad file descriptor)
close(400)                              = -1 EBADF (Bad file descriptor)
close(399)                              = -1 EBADF (Bad file descriptor)
close(398)                              = -1 EBADF (Bad file descriptor)
close(397)                              = -1 EBADF (Bad file descriptor)
close(396)                              = -1 EBADF (Bad file descriptor)
close(395)                              = -1 EBADF (Bad file descriptor)
close(394)                              = -1 EBADF (Bad file descriptor)
close(393)                              = -1 EBADF (Bad file descriptor)
close(392)                              = -1 EBADF (Bad file descriptor)
close(391)                              = -1 EBADF (Bad file descriptor)
close(390)                              = -1 EBADF (Bad file descriptor)
close(389)                              = -1 EBADF (Bad file descriptor)
close(388)                              = -1 EBADF (Bad file descriptor)
close(387)                              = -1 EBADF (Bad file descriptor)
close(386)                              = -1 EBADF (Bad file descriptor)
close(385)                              = -1 EBADF (Bad file descriptor)
close(384)                              = -1 EBADF (Bad file descriptor)
close(383)                              = -1 EBADF (Bad file descriptor)
close(382)                              = -1 EBADF (Bad file descriptor)
close(381)                              = -1 EBADF (Bad file descriptor)
close(380)                              = -1 EBADF (Bad file descriptor)
close(379)                              = -1 EBADF (Bad file descriptor)
close(378)                              = -1 EBADF (Bad file descriptor)
close(377)                              = -1 EBADF (Bad file descriptor)
close(376)                              = -1 EBADF (Bad file descriptor)
close(375)                              = -1 EBADF (Bad file descriptor)
close(374)                              = -1 EBADF (Bad file descriptor)
close(373)                              = -1 EBADF (Bad file descriptor)
close(372)                              = -1 EBADF (Bad file descriptor)
close(371)                              = -1 EBADF (Bad file descriptor)
close(370)                              = -1 EBADF (Bad file descriptor)
close(369)                              = -1 EBADF (Bad file descriptor)
close(368)                              = -1 EBADF (Bad file descriptor)
close(367)                              = -1 EBADF (Bad file descriptor)
close(366)                              = -1 EBADF (Bad file descriptor)
close(365)                              = -1 EBADF (Bad file descriptor)
close(364)                              = -1 EBADF (Bad file descriptor)
close(363)                              = -1 EBADF (Bad file descriptor)
close(362)                              = -1 EBADF (Bad file descriptor)
close(361)                              = -1 EBADF (Bad file descriptor)
close(360)                              = -1 EBADF (Bad file descriptor)
close(359)                              = -1 EBADF (Bad file descriptor)
close(358)                              = -1 EBADF (Bad file descriptor)
close(357)                              = -1 EBADF (Bad file descriptor)
close(356)                              = -1 EBADF (Bad file descriptor)
close(355)                              = -1 EBADF (Bad file descriptor)
close(354)                              = -1 EBADF (Bad file descriptor)
close(353)                              = -1 EBADF (Bad file descriptor)
close(352)                              = -1 EBADF (Bad file descriptor)
close(351)                              = -1 EBADF (Bad file descriptor)
close(350)                              = -1 EBADF (Bad file descriptor)
close(349)                              = -1 EBADF (Bad file descriptor)
close(348)                              = -1 EBADF (Bad file descriptor)
close(347)                              = -1 EBADF (Bad file descriptor)
close(346)                              = -1 EBADF (Bad file descriptor)
close(345)                              = -1 EBADF (Bad file descriptor)
close(344)                              = -1 EBADF (Bad file descriptor)
close(343)                              = -1 EBADF (Bad file descriptor)
close(342)                              = -1 EBADF (Bad file descriptor)
close(341)                              = -1 EBADF (Bad file descriptor)
close(340)                              = -1 EBADF (Bad file descriptor)
close(339)                              = -1 EBADF (Bad file descriptor)
close(338)                              = -1 EBADF (Bad file descriptor)
close(337)                              = -1 EBADF (Bad file descriptor)
close(336)                              = -1 EBADF (Bad file descriptor)
close(335)                              = -1 EBADF (Bad file descriptor)
close(334)                              = -1 EBADF (Bad file descriptor)
close(333)                              = -1 EBADF (Bad file descriptor)
close(332)                              = -1 EBADF (Bad file descriptor)
close(331)                              = -1 EBADF (Bad file descriptor)
close(330)                              = -1 EBADF (Bad file descriptor)
close(329)                              = -1 EBADF (Bad file descriptor)
close(328)                              = -1 EBADF (Bad file descriptor)
close(327)                              = -1 EBADF (Bad file descriptor)
close(326)                              = -1 EBADF (Bad file descriptor)
close(325)                              = -1 EBADF (Bad file descriptor)
close(324)                              = -1 EBADF (Bad file descriptor)
close(323)                              = -1 EBADF (Bad file descriptor)
close(322)                              = -1 EBADF (Bad file descriptor)
close(321)                              = -1 EBADF (Bad file descriptor)
close(320)                              = -1 EBADF (Bad file descriptor)
close(319)                              = -1 EBADF (Bad file descriptor)
close(318)                              = -1 EBADF (Bad file descriptor)
close(317)                              = -1 EBADF (Bad file descriptor)
close(316)                              = -1 EBADF (Bad file descriptor)
close(315)                              = -1 EBADF (Bad file descriptor)
close(314)                              = -1 EBADF (Bad file descriptor)
close(313)                              = -1 EBADF (Bad file descriptor)
close(312)                              = -1 EBADF (Bad file descriptor)
close(311)                              = -1 EBADF (Bad file descriptor)
close(310)                              = -1 EBADF (Bad file descriptor)
close(309)                              = -1 EBADF (Bad file descriptor)
close(308)                              = -1 EBADF (Bad file descriptor)
close(307)                              = -1 EBADF (Bad file descriptor)
close(306)                              = -1 EBADF (Bad file descriptor)
close(305)                              = -1 EBADF (Bad file descriptor)
close(304)                              = -1 EBADF (Bad file descriptor)
close(303)                              = -1 EBADF (Bad file descriptor)
close(302)                              = -1 EBADF (Bad file descriptor)
close(301)                              = -1 EBADF (Bad file descriptor)
close(300)                              = -1 EBADF (Bad file descriptor)
close(299)                              = -1 EBADF (Bad file descriptor)
close(298)                              = -1 EBADF (Bad file descriptor)
close(297)                              = -1 EBADF (Bad file descriptor)
close(296)                              = -1 EBADF (Bad file descriptor)
close(295)                              = -1 EBADF (Bad file descriptor)
close(294)                              = -1 EBADF (Bad file descriptor)
close(293)                              = -1 EBADF (Bad file descriptor)
close(292)                              = -1 EBADF (Bad file descriptor)
close(291)                              = -1 EBADF (Bad file descriptor)
close(290)                              = -1 EBADF (Bad file descriptor)
close(289)                              = -1 EBADF (Bad file descriptor)
close(288)                              = -1 EBADF (Bad file descriptor)
close(287)                              = -1 EBADF (Bad file descriptor)
close(286)                              = -1 EBADF (Bad file descriptor)
close(285)                              = -1 EBADF (Bad file descriptor)
close(284)                              = -1 EBADF (Bad file descriptor)
close(283)                              = -1 EBADF (Bad file descriptor)
close(282)                              = -1 EBADF (Bad file descriptor)
close(281)                              = -1 EBADF (Bad file descriptor)
close(280)                              = -1 EBADF (Bad file descriptor)
close(279)                              = -1 EBADF (Bad file descriptor)
close(278)                              = -1 EBADF (Bad file descriptor)
close(277)                              = -1 EBADF (Bad file descriptor)
close(276)                              = -1 EBADF (Bad file descriptor)
close(275)                              = -1 EBADF (Bad file descriptor)
close(274)                              = -1 EBADF (Bad file descriptor)
close(273)                              = -1 EBADF (Bad file descriptor)
close(272)                              = -1 EBADF (Bad file descriptor)
close(271)                              = -1 EBADF (Bad file descriptor)
close(270)                              = -1 EBADF (Bad file descriptor)
close(269)                              = -1 EBADF (Bad file descriptor)
close(268)                              = -1 EBADF (Bad file descriptor)
close(267)                              = -1 EBADF (Bad file descriptor)
close(266)                              = -1 EBADF (Bad file descriptor)
close(265)                              = -1 EBADF (Bad file descriptor)
close(264)                              = -1 EBADF (Bad file descriptor)
close(263)                              = -1 EBADF (Bad file descriptor)
close(262)                              = -1 EBADF (Bad file descriptor)
close(261)                              = -1 EBADF (Bad file descriptor)
close(260)                              = -1 EBADF (Bad file descriptor)
close(259)                              = -1 EBADF (Bad file descriptor)
close(258)                              = -1 EBADF (Bad file descriptor)
close(257)                              = -1 EBADF (Bad file descriptor)
close(256)                              = -1 EBADF (Bad file descriptor)
close(255)                              = -1 EBADF (Bad file descriptor)
close(254)                              = -1 EBADF (Bad file descriptor)
close(253)                              = -1 EBADF (Bad file descriptor)
close(252)                              = -1 EBADF (Bad file descriptor)
close(251)                              = -1 EBADF (Bad file descriptor)
close(250)                              = -1 EBADF (Bad file descriptor)
close(249)                              = -1 EBADF (Bad file descriptor)
close(248)                              = -1 EBADF (Bad file descriptor)
close(247)                              = -1 EBADF (Bad file descriptor)
close(246)                              = -1 EBADF (Bad file descriptor)
close(245)                              = -1 EBADF (Bad file descriptor)
close(244)                              = -1 EBADF (Bad file descriptor)
close(243)                              = -1 EBADF (Bad file descriptor)
close(242)                              = -1 EBADF (Bad file descriptor)
close(241)                              = -1 EBADF (Bad file descriptor)
close(240)                              = -1 EBADF (Bad file descriptor)
close(239)                              = -1 EBADF (Bad file descriptor)
close(238)                              = -1 EBADF (Bad file descriptor)
close(237)                              = -1 EBADF (Bad file descriptor)
close(236)                              = -1 EBADF (Bad file descriptor)
close(235)                              = -1 EBADF (Bad file descriptor)
close(234)                              = -1 EBADF (Bad file descriptor)
close(233)                              = -1 EBADF (Bad file descriptor)
close(232)                              = -1 EBADF (Bad file descriptor)
close(231)                              = -1 EBADF (Bad file descriptor)
close(230)                              = -1 EBADF (Bad file descriptor)
close(229)                              = -1 EBADF (Bad file descriptor)
close(228)                              = -1 EBADF (Bad file descriptor)
close(227)                              = -1 EBADF (Bad file descriptor)
close(226)                              = -1 EBADF (Bad file descriptor)
close(225)                              = -1 EBADF (Bad file descriptor)
close(224)                              = -1 EBADF (Bad file descriptor)
close(223)                              = -1 EBADF (Bad file descriptor)
close(222)                              = -1 EBADF (Bad file descriptor)
close(221)                              = -1 EBADF (Bad file descriptor)
close(220)                              = -1 EBADF (Bad file descriptor)
close(219)                              = -1 EBADF (Bad file descriptor)
close(218)                              = -1 EBADF (Bad file descriptor)
close(217)                              = -1 EBADF (Bad file descriptor)
close(216)                              = -1 EBADF (Bad file descriptor)
close(215)                              = -1 EBADF (Bad file descriptor)
close(214)                              = -1 EBADF (Bad file descriptor)
close(213)                              = -1 EBADF (Bad file descriptor)
close(212)                              = -1 EBADF (Bad file descriptor)
close(211)                              = -1 EBADF (Bad file descriptor)
close(210)                              = -1 EBADF (Bad file descriptor)
close(209)                              = -1 EBADF (Bad file descriptor)
close(208)                              = -1 EBADF (Bad file descriptor)
close(207)                              = -1 EBADF (Bad file descriptor)
close(206)                              = -1 EBADF (Bad file descriptor)
close(205)                              = -1 EBADF (Bad file descriptor)
close(204)                              = -1 EBADF (Bad file descriptor)
close(203)                              = -1 EBADF (Bad file descriptor)
close(202)                              = -1 EBADF (Bad file descriptor)
close(201)                              = -1 EBADF (Bad file descriptor)
close(200)                              = -1 EBADF (Bad file descriptor)
close(199)                              = -1 EBADF (Bad file descriptor)
close(198)                              = -1 EBADF (Bad file descriptor)
close(197)                              = -1 EBADF (Bad file descriptor)
close(196)                              = -1 EBADF (Bad file descriptor)
close(195)                              = -1 EBADF (Bad file descriptor)
close(194)                              = -1 EBADF (Bad file descriptor)
close(193)                              = -1 EBADF (Bad file descriptor)
close(192)                              = -1 EBADF (Bad file descriptor)
close(191)                              = -1 EBADF (Bad file descriptor)
close(190)                              = -1 EBADF (Bad file descriptor)
close(189)                              = -1 EBADF (Bad file descriptor)
close(188)                              = -1 EBADF (Bad file descriptor)
close(187)                              = -1 EBADF (Bad file descriptor)
close(186)                              = -1 EBADF (Bad file descriptor)
close(185)                              = -1 EBADF (Bad file descriptor)
close(184)                              = -1 EBADF (Bad file descriptor)
close(183)                              = -1 EBADF (Bad file descriptor)
close(182)                              = -1 EBADF (Bad file descriptor)
close(181)                              = -1 EBADF (Bad file descriptor)
close(180)                              = -1 EBADF (Bad file descriptor)
close(179)                              = -1 EBADF (Bad file descriptor)
close(178)                              = -1 EBADF (Bad file descriptor)
close(177)                              = -1 EBADF (Bad file descriptor)
close(176)                              = -1 EBADF (Bad file descriptor)
close(175)                              = -1 EBADF (Bad file descriptor)
close(174)                              = -1 EBADF (Bad file descriptor)
close(173)                              = -1 EBADF (Bad file descriptor)
close(172)                              = -1 EBADF (Bad file descriptor)
close(171)                              = -1 EBADF (Bad file descriptor)
close(170)                              = -1 EBADF (Bad file descriptor)
close(169)                              = -1 EBADF (Bad file descriptor)
close(168)                              = -1 EBADF (Bad file descriptor)
close(167)                              = -1 EBADF (Bad file descriptor)
close(166)                              = -1 EBADF (Bad file descriptor)
close(165)                              = -1 EBADF (Bad file descriptor)
close(164)                              = -1 EBADF (Bad file descriptor)
close(163)                              = -1 EBADF (Bad file descriptor)
close(162)                              = -1 EBADF (Bad file descriptor)
close(161)                              = -1 EBADF (Bad file descriptor)
close(160)                              = -1 EBADF (Bad file descriptor)
close(159)                              = -1 EBADF (Bad file descriptor)
close(158)                              = -1 EBADF (Bad file descriptor)
close(157)                              = -1 EBADF (Bad file descriptor)
close(156)                              = -1 EBADF (Bad file descriptor)
close(155)                              = -1 EBADF (Bad file descriptor)
close(154)                              = -1 EBADF (Bad file descriptor)
close(153)                              = -1 EBADF (Bad file descriptor)
close(152)                              = -1 EBADF (Bad file descriptor)
close(151)                              = -1 EBADF (Bad file descriptor)
close(150)                              = -1 EBADF (Bad file descriptor)
close(149)                              = -1 EBADF (Bad file descriptor)
close(148)                              = -1 EBADF (Bad file descriptor)
close(147)                              = -1 EBADF (Bad file descriptor)
close(146)                              = -1 EBADF (Bad file descriptor)
close(145)                              = -1 EBADF (Bad file descriptor)
close(144)                              = -1 EBADF (Bad file descriptor)
close(143)                              = -1 EBADF (Bad file descriptor)
close(142)                              = -1 EBADF (Bad file descriptor)
close(141)                              = -1 EBADF (Bad file descriptor)
close(140)                              = -1 EBADF (Bad file descriptor)
close(139)                              = -1 EBADF (Bad file descriptor)
close(138)                              = -1 EBADF (Bad file descriptor)
close(137)                              = -1 EBADF (Bad file descriptor)
close(136)                              = -1 EBADF (Bad file descriptor)
close(135)                              = -1 EBADF (Bad file descriptor)
close(134)                              = -1 EBADF (Bad file descriptor)
close(133)                              = -1 EBADF (Bad file descriptor)
close(132)                              = -1 EBADF (Bad file descriptor)
close(131)                              = -1 EBADF (Bad file descriptor)
close(130)                              = -1 EBADF (Bad file descriptor)
close(129)                              = -1 EBADF (Bad file descriptor)
close(128)                              = -1 EBADF (Bad file descriptor)
close(127)                              = -1 EBADF (Bad file descriptor)
close(126)                              = -1 EBADF (Bad file descriptor)
close(125)                              = -1 EBADF (Bad file descriptor)
close(124)                              = -1 EBADF (Bad file descriptor)
close(123)                              = -1 EBADF (Bad file descriptor)
close(122)                              = -1 EBADF (Bad file descriptor)
close(121)                              = -1 EBADF (Bad file descriptor)
close(120)                              = -1 EBADF (Bad file descriptor)
close(119)                              = -1 EBADF (Bad file descriptor)
close(118)                              = -1 EBADF (Bad file descriptor)
close(117)                              = -1 EBADF (Bad file descriptor)
close(116)                              = -1 EBADF (Bad file descriptor)
close(115)                              = -1 EBADF (Bad file descriptor)
close(114)                              = -1 EBADF (Bad file descriptor)
close(113)                              = -1 EBADF (Bad file descriptor)
close(112)                              = -1 EBADF (Bad file descriptor)
close(111)                              = -1 EBADF (Bad file descriptor)
close(110)                              = -1 EBADF (Bad file descriptor)
close(109)                              = -1 EBADF (Bad file descriptor)
close(108)                              = -1 EBADF (Bad file descriptor)
close(107)                              = -1 EBADF (Bad file descriptor)
close(106)                              = -1 EBADF (Bad file descriptor)
close(105)                              = -1 EBADF (Bad file descriptor)
close(104)                              = -1 EBADF (Bad file descriptor)
close(103)                              = -1 EBADF (Bad file descriptor)
close(102)                              = -1 EBADF (Bad file descriptor)
close(101)                              = -1 EBADF (Bad file descriptor)
close(100)                              = -1 EBADF (Bad file descriptor)
close(99)                               = -1 EBADF (Bad file descriptor)
close(98)                               = -1 EBADF (Bad file descriptor)
close(97)                               = -1 EBADF (Bad file descriptor)
close(96)                               = -1 EBADF (Bad file descriptor)
close(95)                               = -1 EBADF (Bad file descriptor)
close(94)                               = -1 EBADF (Bad file descriptor)
close(93)                               = -1 EBADF (Bad file descriptor)
close(92)                               = -1 EBADF (Bad file descriptor)
close(91)                               = -1 EBADF (Bad file descriptor)
close(90)                               = -1 EBADF (Bad file descriptor)
close(89)                               = -1 EBADF (Bad file descriptor)
close(88)                               = -1 EBADF (Bad file descriptor)
close(87)                               = -1 EBADF (Bad file descriptor)
close(86)                               = -1 EBADF (Bad file descriptor)
close(85)                               = -1 EBADF (Bad file descriptor)
close(84)                               = -1 EBADF (Bad file descriptor)
close(83)                               = -1 EBADF (Bad file descriptor)
close(82)                               = -1 EBADF (Bad file descriptor)
close(81)                               = -1 EBADF (Bad file descriptor)
close(80)                               = -1 EBADF (Bad file descriptor)
close(79)                               = -1 EBADF (Bad file descriptor)
close(78)                               = -1 EBADF (Bad file descriptor)
close(77)                               = -1 EBADF (Bad file descriptor)
close(76)                               = -1 EBADF (Bad file descriptor)
close(75)                               = -1 EBADF (Bad file descriptor)
close(74)                               = -1 EBADF (Bad file descriptor)
close(73)                               = -1 EBADF (Bad file descriptor)
close(72)                               = -1 EBADF (Bad file descriptor)
close(71)                               = -1 EBADF (Bad file descriptor)
close(70)                               = -1 EBADF (Bad file descriptor)
close(69)                               = -1 EBADF (Bad file descriptor)
close(68)                               = -1 EBADF (Bad file descriptor)
close(67)                               = -1 EBADF (Bad file descriptor)
close(66)                               = -1 EBADF (Bad file descriptor)
close(65)                               = -1 EBADF (Bad file descriptor)
close(64)                               = -1 EBADF (Bad file descriptor)
close(63)                               = -1 EBADF (Bad file descriptor)
close(62)                               = -1 EBADF (Bad file descriptor)
close(61)                               = -1 EBADF (Bad file descriptor)
close(60)                               = -1 EBADF (Bad file descriptor)
close(59)                               = -1 EBADF (Bad file descriptor)
close(58)                               = -1 EBADF (Bad file descriptor)
close(57)                               = -1 EBADF (Bad file descriptor)
close(56)                               = -1 EBADF (Bad file descriptor)
close(55)                               = -1 EBADF (Bad file descriptor)
close(54)                               = -1 EBADF (Bad file descriptor)
close(53)                               = -1 EBADF (Bad file descriptor)
close(52)                               = -1 EBADF (Bad file descriptor)
close(51)                               = -1 EBADF (Bad file descriptor)
close(50)                               = -1 EBADF (Bad file descriptor)
close(49)                               = -1 EBADF (Bad file descriptor)
close(48)                               = -1 EBADF (Bad file descriptor)
close(47)                               = -1 EBADF (Bad file descriptor)
close(46)                               = -1 EBADF (Bad file descriptor)
close(45)                               = -1 EBADF (Bad file descriptor)
close(44)                               = -1 EBADF (Bad file descriptor)
close(43)                               = -1 EBADF (Bad file descriptor)
close(42)                               = -1 EBADF (Bad file descriptor)
close(41)                               = -1 EBADF (Bad file descriptor)
close(40)                               = -1 EBADF (Bad file descriptor)
close(39)                               = -1 EBADF (Bad file descriptor)
close(38)                               = -1 EBADF (Bad file descriptor)
close(37)                               = -1 EBADF (Bad file descriptor)
close(36)                               = -1 EBADF (Bad file descriptor)
close(35)                               = -1 EBADF (Bad file descriptor)
close(34)                               = -1 EBADF (Bad file descriptor)
close(33)                               = -1 EBADF (Bad file descriptor)
close(32)                               = -1 EBADF (Bad file descriptor)
close(31)                               = -1 EBADF (Bad file descriptor)
close(30)                               = -1 EBADF (Bad file descriptor)
close(29)                               = -1 EBADF (Bad file descriptor)
close(28)                               = -1 EBADF (Bad file descriptor)
close(27)                               = -1 EBADF (Bad file descriptor)
close(26)                               = -1 EBADF (Bad file descriptor)
close(25)                               = -1 EBADF (Bad file descriptor)
close(24)                               = -1 EBADF (Bad file descriptor)
close(23)                               = -1 EBADF (Bad file descriptor)
close(22)                               = -1 EBADF (Bad file descriptor)
close(21)                               = -1 EBADF (Bad file descriptor)
close(20)                               = -1 EBADF (Bad file descriptor)
close(19)                               = -1 EBADF (Bad file descriptor)
close(18)                               = -1 EBADF (Bad file descriptor)
close(17)                               = -1 EBADF (Bad file descriptor)
close(16)                               = -1 EBADF (Bad file descriptor)
close(15)                               = -1 EBADF (Bad file descriptor)
close(14)                               = -1 EBADF (Bad file descriptor)
close(13)                               = -1 EBADF (Bad file descriptor)
close(12)                               = -1 EBADF (Bad file descriptor)
close(11)                               = -1 EBADF (Bad file descriptor)
close(10)                               = -1 EBADF (Bad file descriptor)
close(9)                                = -1 EBADF (Bad file descriptor)
close(8)                                = -1 EBADF (Bad file descriptor)
close(7)                                = -1 EBADF (Bad file descriptor)
close(6)                                = 0
close(5)                                = -1 EBADF (Bad file descriptor)
close(4)                                = 0
close(3)                                = -1 EBADF (Bad file descriptor)
brk(0)                                  = 0x956000
brk(0x978000)                           = 0x978000
uname({sys="Linux", node="pc-francois", ...}) = 0
geteuid()                               = 0
chdir("/")                              = 0
umask(022)                              = 022
mkdir("/var/lib/dhcpcd", 0755)          = -1 EEXIST (File exists)
mkdir("/etc", 0755)                     = -1 EEXIST (File exists)
open("/var/run/dhcpcd-wlan0.pid", O_RDONLY) = -1 ENOENT (No such file or directory)
open("/var/run/dhcpcd-wlan0.pid", O_WRONLY|O_CREAT|O_NONBLOCK, 0664) = 3
flock(3, LOCK_EX|LOCK_NB)               = 0
fcntl(3, F_GETFD)                       = 0
fcntl(3, F_SETFD, FD_CLOEXEC)           = 0
ftruncate(3, 0)                         = 0
pwrite(3, "16589", 5, 0)                = 5
open("/etc/localtime", O_RDONLY)        = 4
fstat(4, {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
fstat(4, {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fdcb2552000
read(4, "TZif2\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\n\0\0\0\n\0\0\0\0"..., 4096) = 2944
lseek(4, -1877, SEEK_CUR)               = 1067
read(4, "TZif2\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\f\0\0\0\f\0\0\0\0"..., 4096) = 1877
close(4)                                = 0
munmap(0x7fdcb2552000, 4096)            = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
socket(PF_FILE, SOCK_DGRAM, 0)          = 4
fcntl(4, F_SETFD, FD_CLOEXEC)           = 0
connect(4, {sa_family=AF_FILE, path="/dev/log"}, 110) = -1 EPROTOTYPE (Protocol wrong type for socket)
close(4)                                = 0
socket(PF_FILE, SOCK_STREAM, 0)         = 4
fcntl(4, F_SETFD, FD_CLOEXEC)           = 0
connect(4, {sa_family=AF_FILE, path="/dev/log"}, 110) = 0
sendto(4, "<134>Jul 23 14:34:43 dhcpcd[1658"..., 65, MSG_NOSIGNAL, NULL, 0) = 65
open("/dev/urandom", O_RDONLY)          = 5
read(5, "\202\255\266\350\205\376d\322", 8) = 8
close(5)                                = 0
socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = 5
ioctl(5, SIOCGIFHWADDR, {ifr_name="wlan0", ifr_hwaddr=00:13:e8:c1:41:b9}) = 0
ioctl(5, SIOCGIFMTU, {ifr_name="wlan0", ifr_mtu=1500}) = 0
ioctl(5, SIOCGIFFLAGS, {ifr_name="wlan0", ifr_flags=IFF_UP|IFF_BROADCAST|IFF_RUNNING|IFF_MULTICAST}) = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
sendto(4, "<134>Jul 23 14:34:43 dhcpcd[1658"..., 80, MSG_NOSIGNAL, NULL, 0) = 80
close(5)                                = 0
socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = 5
ioctl(5, SIOCGIFCONF, {40, {{"lo", {AF_INET, inet_addr("127.0.0.1")}}}}) = 0
ioctl(5, SIOCGIFCONF, {40, {{"lo", {AF_INET, inet_addr("127.0.0.1")}}}}) = 0
close(5)                                = 0
open("/var/lib/dhcpcd/dhcpcd.duid", O_RDONLY) = 5
fstat(5, {st_mode=S_IFREG|0644, st_size=42, ...}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fdcb2552000
read(5, "00:01:00:01:0E:F9:52:9E:00:13:E8"..., 4096) = 42
close(5)                                = 0
munmap(0x7fdcb2552000, 4096)            = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
sendto(4, "<134>Jul 23 14:34:43 dhcpcd[1658"..., 92, MSG_NOSIGNAL, NULL, 0) = 92
access("/proc/net", R_OK)               = 0
access("/proc/net/unix", R_OK)          = 0
socket(PF_FILE, SOCK_DGRAM, 0)          = 5
ioctl(5, SIOCGIFINDEX, {ifr_name="wlan0", ifr_index=6}) = 0
close(5)                                = 0
pipe([5, 6])                            = 0
fcntl(5, F_GETFD)                       = 0
fcntl(5, F_SETFD, FD_CLOEXEC)           = 0
fcntl(6, F_GETFD)                       = 0
fcntl(6, F_SETFD, FD_CLOEXEC)           = 0
rt_sigaction(SIGCHLD, {SIG_DFL}, NULL, 8) = 0
rt_sigaction(SIGHUP, {0x40a6f1, [], SA_RESTORER, 0x7fdcb1e23430}, NULL, 8) = 0
rt_sigaction(SIGALRM, {0x40a6f1, [], SA_RESTORER, 0x7fdcb1e23430}, NULL, 8) = 0
rt_sigaction(SIGTERM, {0x40a6f1, [], SA_RESTORER, 0x7fdcb1e23430}, NULL, 8) = 0
rt_sigaction(SIGINT, {0x40a6f1, [], SA_RESTORER, 0x7fdcb1e23430}, NULL, 8) = 0
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) = 7
setsockopt(7, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
setsockopt(7, SOL_SOCKET, SO_RCVBUF, [1], 4) = 0
setsockopt(7, SOL_SOCKET, SO_BINDTODEVICE, "wlan0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 40) = 0
bind(7, {sa_family=AF_INET, sin_port=htons(68), sin_addr=inet_addr("0.0.0.0")}, 128) = 0
fcntl(7, F_GETFD)                       = 0
fcntl(7, F_SETFD, FD_CLOEXEC)           = 0
socket(PF_PACKET, SOCK_DGRAM, 8)        = 8
fcntl(8, F_GETFD)                       = 0
fcntl(8, F_SETFD, FD_CLOEXEC)           = 0
socket(PF_FILE, SOCK_DGRAM, 0)          = 9
ioctl(9, SIOCGIFINDEX, {ifr_name="wlan0", ifr_index=6}) = 0
close(9)                                = 0
setsockopt(8, SOL_SOCKET, SO_ATTACH_FILTER, "\v\0\0\0\0\0\0\0@\366`\0\0\0\0\0", 16) = 0
bind(8, {sa_family=AF_PACKET, proto=0x800, if6, pkttype=PACKET_HOST, addr(0)={0, }, 128) = 0
clock_getres(CLOCK_MONOTONIC, {0, 1})   = 0
clock_gettime(CLOCK_MONOTONIC, {2373, 288415417}) = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
sendto(4, "<134>Jul 23 14:34:43 dhcpcd[1658"..., 68, MSG_NOSIGNAL, NULL, 0) = 68
clock_gettime(CLOCK_MONOTONIC, {2373, 288723766}) = 0
clock_gettime(CLOCK_MONOTONIC, {2373, 288753239}) = 0
socket(PF_FILE, SOCK_DGRAM, 0)          = 9
ioctl(9, SIOCGIFINDEX, {ifr_name="wlan0", ifr_index=6}) = 0
close(9)                                = 0
sendto(8, "E\20\1H\0\0@\0@\0219\226\0\0\0\0\377\377\377\377\0D\0C\0014\345(\1\1\6\0"..., 328, 0, {sa_family=AF_PACKET, proto=0x800, if6, pkttype=PACKET_HOST, addr(6)={256, ffffffffffff}, 128) = 328
clock_gettime(CLOCK_MONOTONIC, {2373, 288959900}) = 0
clock_gettime(CLOCK_MONOTONIC, {2373, 288986719}) = 0
poll([{fd=5, events=POLLIN}, {fd=8, events=POLLIN, revents=POLLIN}], 2, 3000) = 1
clock_gettime(CLOCK_MONOTONIC, {2373, 383367778}) = 0
read(8, "E\0\2@ \\\0\0@\21\226\250\300\250\1\1\377\377\377\377\0C\0D\2,\331:\2\1\6\0"..., 4096) = 576
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
sendto(4, "<134>Jul 23 14:34:44 dhcpcd[1658"..., 80, MSG_NOSIGNAL, NULL, 0) = 80
clock_gettime(CLOCK_MONOTONIC, {2373, 383762661}) = 0
clock_gettime(CLOCK_MONOTONIC, {2373, 383790109}) = 0
socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = 9
ioctl(9, SIOCGIFMTU, {ifr_name="wlan0", ifr_mtu=1500}) = 0
close(9)                                = 0
socket(PF_FILE, SOCK_DGRAM, 0)          = 9
ioctl(9, SIOCGIFINDEX, {ifr_name="wlan0", ifr_index=6}) = 0
close(9)                                = 0
sendto(8, "E\20\1c\0\0@\0@\0219{\0\0\0\0\377\377\377\377\0D\0C\1O\21m\1\1\6\0"..., 355, 0, {sa_family=AF_PACKET, proto=0x800, if6, pkttype=PACKET_HOST, addr(6)={256, ffffffffffff}, 128) = 355
clock_gettime(CLOCK_MONOTONIC, {2373, 384098318}) = 0
clock_gettime(CLOCK_MONOTONIC, {2373, 384125906}) = 0
poll([{fd=5, events=POLLIN}, {fd=8, events=POLLIN, revents=POLLIN}], 2, 3000) = 1
clock_gettime(CLOCK_MONOTONIC, {2373, 511678081}) = 0
read(8, "E\0\2@ _\0\0@\21\226\245\300\250\1\1\377\377\377\377\0C\0D\2,\326:\2\1\6\0"..., 4096) = 576
close(8)                                = 0
close(7)                                = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
sendto(4, "<134>Jul 23 14:34:44 dhcpcd[1658"..., 98, MSG_NOSIGNAL, NULL, 0) = 98
socket(PF_PACKET, SOCK_DGRAM, 1544)     = 7
fcntl(7, F_GETFD)                       = 0
fcntl(7, F_SETFD, FD_CLOEXEC)           = 0
socket(PF_FILE, SOCK_DGRAM, 0)          = 8
ioctl(8, SIOCGIFINDEX, {ifr_name="wlan0", ifr_index=6}) = 0
close(8)                                = 0
setsockopt(7, SOL_SOCKET, SO_ATTACH_FILTER, "\6\0\0\0\0\0\0\0\0\366`\0\0\0\0\0", 16) = 0
bind(7, {sa_family=AF_PACKET, proto=0x806, if6, pkttype=PACKET_HOST, addr(0)={0, }, 128) = 0
socket(PF_FILE, SOCK_DGRAM, 0)          = 8
ioctl(8, SIOCGIFINDEX, {ifr_name="wlan0", ifr_index=6}) = 0
close(8)                                = 0
sendto(7, "\0\1\10\0\6\4\0\1\0\23\350\301A\271\0\0\0\0\0\0\0\0\0\0\300\250\1\2", 28, 0, {sa_family=AF_PACKET, proto=0x806, if6, pkttype=PACKET_HOST, addr(6)={256, ffffffffffff}, 128) = 28
clock_gettime(CLOCK_MONOTONIC, {2373, 519560787}) = 0
poll([{fd=5, events=POLLIN}, {fd=7, events=POLLIN}], 2, 200) = 0
socket(PF_FILE, SOCK_DGRAM, 0)          = 8
ioctl(8, SIOCGIFINDEX, {ifr_name="wlan0", ifr_index=6}) = 0
close(8)                                = 0
sendto(7, "\0\1\10\0\6\4\0\1\0\23\350\301A\271\0\0\0\0\0\0\0\0\0\0\300\250\1\2", 28, 0, {sa_family=AF_PACKET, proto=0x806, if6, pkttype=PACKET_HOST, addr(6)={256, ffffffffffff}, 128) = 28
clock_gettime(CLOCK_MONOTONIC, {2373, 720436875}) = 0
poll([{fd=5, events=POLLIN}, {fd=7, events=POLLIN}], 2, 200) = 0
socket(PF_FILE, SOCK_DGRAM, 0)          = 8
ioctl(8, SIOCGIFINDEX, {ifr_name="wlan0", ifr_index=6}) = 0
close(8)                                = 0
sendto(7, "\0\1\10\0\6\4\0\1\0\23\350\301A\271\0\0\0\0\0\0\0\0\0\0\300\250\1\2", 28, 0, {sa_family=AF_PACKET, proto=0x806, if6, pkttype=PACKET_HOST, addr(6)={256, ffffffffffff}, 128) = 28
clock_gettime(CLOCK_MONOTONIC, {2373, 921420938}) = 0
poll([{fd=5, events=POLLIN}, {fd=7, events=POLLIN}], 2, 200) = 0
socket(PF_FILE, SOCK_DGRAM, 0)          = 8
ioctl(8, SIOCGIFINDEX, {ifr_name="wlan0", ifr_index=6}) = 0
close(8)                                = 0
sendto(7, "\0\1\10\0\6\4\0\1\0\23\350\301A\271\300\250\1\2\0\23\350\301A\271\300\250\1\2", 28, 0, {sa_family=AF_PACKET, proto=0x806, if6, pkttype=PACKET_HOST, addr(6)={256, ffffffffffff}, 128) = 28
clock_gettime(CLOCK_MONOTONIC, {2374, 123433136}) = 0
poll([{fd=5, events=POLLIN}, {fd=7, events=POLLIN}], 2, 200) = 0
socket(PF_FILE, SOCK_DGRAM, 0)          = 8
ioctl(8, SIOCGIFINDEX, {ifr_name="wlan0", ifr_index=6}) = 0
close(8)                                = 0
sendto(7, "\0\1\10\0\6\4\0\1\0\23\350\301A\271\300\250\1\2\0\23\350\301A\271\300\250\1\2", 28, 0, {sa_family=AF_PACKET, proto=0x806, if6, pkttype=PACKET_HOST, addr(6)={256, ffffffffffff}, 128) = 28
clock_gettime(CLOCK_MONOTONIC, {2374, 324416850}) = 0
poll([{fd=5, events=POLLIN}, {fd=7, events=POLLIN}], 2, 200) = 0
close(7)                                = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
sendto(4, "<134>Jul 23 14:34:45 dhcpcd[1658"..., 80, MSG_NOSIGNAL, NULL, 0) = 80
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
sendto(4, "<134>Jul 23 14:34:45 dhcpcd[1658"..., 92, MSG_NOSIGNAL, NULL, 0) = 92
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
sendto(4, "<134>Jul 23 14:34:45 dhcpcd[1658"..., 91, MSG_NOSIGNAL, NULL, 0) = 91
socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = 7
ioctl(7, SIOCSIFMTU, 0x7fffba552bb0)    = 0
close(7)                                = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
sendto(4, "<134>Jul 23 14:34:45 dhcpcd[1658"..., 76, MSG_NOSIGNAL, NULL, 0) = 76
socket(PF_FILE, SOCK_DGRAM, 0)          = 7
ioctl(7, SIOCGIFINDEX, {ifr_name="wlan0", ifr_index=6}) = 0
close(7)                                = 0
socket(PF_NETLINK, SOCK_RAW, 0)         = 7
bind(7, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 0
sendmsg(7, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"4\0\0\0\24\0\5\5\1\0\0\0\0\0\0\0\2\30\0\0\6\0\0\0\n\0\3\0wlan"..., 52}], msg_controllen=0, msg_flags=0}, 0) = 52
recvmsg(7, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"$\0\0\0\2\0\0\0\1\0\0\0\315@\0\0\0\0\0\0004\0\0\0\24\0\5\5\1\0\0\0"..., 256}], msg_controllen=0, msg_flags=0}, 0) = 36
close(7)                                = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
sendto(4, "<134>Jul 23 14:34:45 dhcpcd[1658"..., 86, MSG_NOSIGNAL, NULL, 0) = 86
socket(PF_FILE, SOCK_DGRAM, 0)          = 7
ioctl(7, SIOCGIFINDEX, {ifr_name="wlan0", ifr_index=6}) = 0
close(7)                                = 0
socket(PF_NETLINK, SOCK_RAW, 0)         = 7
bind(7, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 0
sendmsg(7, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"<\0\0\0\30\0\5\6\2\0\0\0\0\0\0\0\2\30\0\0\376\3\375\1\0\0\0\0\10\0\1\0"..., 60}], msg_controllen=0, msg_flags=0}, 0) = 60
recvmsg(7, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"$\0\0\0\2\0\0\0\2\0\0\0\315@\0\0\0\0\0\0<\0\0\0\30\0\5\6\2\0\0\0"..., 256}], msg_controllen=0, msg_flags=0}, 0) = 36
close(7)                                = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
sendto(4, "<134>Jul 23 14:34:45 dhcpcd[1658"..., 85, MSG_NOSIGNAL, NULL, 0) = 85
socket(PF_FILE, SOCK_DGRAM, 0)          = 7
ioctl(7, SIOCGIFINDEX, {ifr_name="wlan0", ifr_index=6}) = 0
close(7)                                = 0
socket(PF_NETLINK, SOCK_RAW, 0)         = 7
bind(7, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 0
sendmsg(7, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"<\0\0\0\31\0\5\0\3\0\0\0\0\0\0\0\2\30\0\0\376\0\377\0\0\0\0\0\10\0\1\0"..., 60}], msg_controllen=0, msg_flags=0}, 0) = 60
recvmsg(7, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"$\0\0\0\2\0\0\0\3\0\0\0\315@\0\0\0\0\0\0<\0\0\0\31\0\5\0\3\0\0\0"..., 256}], msg_controllen=0, msg_flags=0}, 0) = 36
close(7)                                = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
sendto(4, "<134>Jul 23 14:34:45 dhcpcd[1658"..., 92, MSG_NOSIGNAL, NULL, 0) = 92
socket(PF_FILE, SOCK_DGRAM, 0)          = 7
ioctl(7, SIOCGIFINDEX, {ifr_name="wlan0", ifr_index=6}) = 0
close(7)                                = 0
socket(PF_NETLINK, SOCK_RAW, 0)         = 7
bind(7, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 0
sendmsg(7, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"<\0\0\0\30\0\5\6\4\0\0\0\0\0\0\0\2\0\0\0\376\3\0\1\0\0\0\0\10\0\1\0"..., 60}], msg_controllen=0, msg_flags=0}, 0) = 60
recvmsg(7, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"$\0\0\0\2\0\0\0\4\0\0\0\315@\0\0\0\0\0\0<\0\0\0\30\0\5\6\4\0\0\0"..., 256}], msg_controllen=0, msg_flags=0}, 0) = 36
close(7)                                = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
sendto(4, "<134>Jul 23 14:34:45 dhcpcd[1658"..., 86, MSG_NOSIGNAL, NULL, 0) = 86
socket(PF_FILE, SOCK_DGRAM, 0)          = 7
ioctl(7, SIOCGIFINDEX, {ifr_name="wlan0", ifr_index=6}) = 0
close(7)                                = 0
socket(PF_NETLINK, SOCK_RAW, 0)         = 7
bind(7, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 0
sendmsg(7, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"<\0\0\0\30\0\5\6\5\0\0\0\0\0\0\0\2\20\0\0\376\3\375\1\0\0\0\0\10\0\1\0"..., 60}], msg_controllen=0, msg_flags=0}, 0) = 60
recvmsg(7, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"$\0\0\0\2\0\0\0\5\0\0\0\315@\0\0\0\0\0\0<\0\0\0\30\0\5\6\5\0\0\0"..., 256}], msg_controllen=0, msg_flags=0}, 0) = 36
close(7)                                = 0
stat("/usr/local/bin/resolvconf", 0x7fffba552b40) = -1 ENOENT (No such file or directory)
stat("/usr/local/sbin/resolvconf", 0x7fffba552b40) = -1 ENOENT (No such file or directory)
stat("/bin/resolvconf", 0x7fffba552b40) = -1 ENOENT (No such file or directory)
stat("/usr/bin/resolvconf", 0x7fffba552b40) = -1 ENOENT (No such file or directory)
stat("/usr/sbin/resolvconf", 0x7fffba552b40) = -1 ENOENT (No such file or directory)
stat("/usr/bin/X11/resolvconf", 0x7fffba552b40) = -1 ENOENT (No such file or directory)
stat("/usr/X11R6/bin/resolvconf", 0x7fffba552b40) = -1 ENOENT (No such file or directory)
stat("/usr/games/resolvconf", 0x7fffba552b40) = -1 ENOENT (No such file or directory)
stat("/sbin/resolvconf", 0x7fffba552b40) = -1 ENOENT (No such file or directory)
stat("/root/bin/resolvconf", 0x7fffba552b40) = -1 ENOENT (No such file or directory)
stat("/usr/kde/3.5/bin/resolvconf", 0x7fffba552b40) = -1 ENOENT (No such file or directory)
stat("/opt/bin/resolvconf", 0x7fffba552b40) = -1 ENOENT (No such file or directory)
open("/etc/resolv.conf", O_WRONLY|O_CREAT|O_TRUNC, 0666) = 7
fstat(7, {st_mode=S_IFREG|0644, st_size=0, ...}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fdcb2552000
write(7, "# Generated by dhcpcd for interf"..., 121) = 121
close(7)                                = 0
munmap(0x7fdcb2552000, 4096)            = 0
open("/etc/resolv.conf", O_RDONLY)      = 7
fstat(7, {st_mode=S_IFREG|0644, st_size=121, ...}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fdcb2552000
read(7, "# Generated by dhcpcd for interf"..., 4096) = 121
read(7, "", 4096)                       = 0
close(7)                                = 0
munmap(0x7fdcb2552000, 4096)            = 0
uname({sys="Linux", node="pc-francois", ...}) = 0
uname({sys="Linux", node="pc-francois", ...}) = 0
open("/var/lib/dhcpcd/dhcpcd-wlan0.info", O_WRONLY|O_CREAT|O_TRUNC, 0666) = 7
fstat(7, {st_mode=S_IFREG|0644, st_size=0, ...}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fdcb2552000
write(7, "IPADDR=\'192.168.1.2\'\nNETMASK=\'25"..., 439) = 439
close(7)                                = 0
munmap(0x7fdcb2552000, 4096)            = 0
stat("/etc/dhcpcd.sh", 0x7fffba552b60)  = -1 ENOENT (No such file or directory)
rt_sigprocmask(SIG_SETMASK, ~[RTMIN RT_1], [], 8) = 0
clone(child_stack=0, flags=CLONE_CHILD_CLEARTID|CLONE_CHILD_SETTID|SIGCHLD, child_tidptr=0x7fdcb2527780) = 16591
rt_sigaction(SIGHUP, {SIG_DFL}, NULL, 8) = 0
rt_sigaction(SIGALRM, {SIG_DFL}, NULL, 8) = 0
rt_sigaction(SIGTERM, {SIG_DFL}, NULL, 8) = 0
rt_sigaction(SIGINT, {SIG_DFL}, NULL, 8) = 0
ftruncate(3, 0)                         = 0
pwrite(3, "16591", 5, 0)                = 5
close(3)                                = 0
rt_sigprocmask(SIG_SETMASK, [], NULL, 8) = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2944, ...}) = 0
sendto(4, "<134>Jul 23 14:34:45 dhcpcd[1658"..., 51, MSG_NOSIGNAL, NULL, 0) = 51
exit_group(0)                           = ?

--------------070907010302060305020807--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
