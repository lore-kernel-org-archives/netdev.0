From: kernel test robot <xiaolong.ye@intel.com>
Subject: [lkp-robot] [net]  e445e46642: ltp-pan reported some tests FAIL
Date: Wed, 3 May 2017 10:07:41 +0800
Message-ID: <20170503020741.GF14967@yexl-desktop>
References: <20170427071202.84403-1-donatas.abraitis@gmail.com>
Reply-To: kernel test robot <xiaolong.ye@intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Q0rSlbzrZN6k9QnT"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        stable@vger.kernel.org, donatas.abraitis@gmail.com, lkp@01.org,
        ltp@lists.linux.it
To: Donatas Abraitis <donatas.abraitis@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:22187 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750950AbdECCJr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 2 May 2017 22:09:47 -0400
Content-Disposition: inline
In-Reply-To: <20170427071202.84403-1-donatas.abraitis@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Q0rSlbzrZN6k9QnT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


FYI, we noticed the following commit:

commit: e445e46642deb36af94d8289f6351b122e6bd8f1 ("net: ipv6: make sure multicast packets are not forwarded beyond the different scopes")
url: https://github.com/0day-ci/linux/commits/Donatas-Abraitis/net-ipv6-make-sure-multicast-packets-are-not-forwarded-beyond-the-different-scopes/20170428-013707


in testcase: ltp
with following parameters:

	test: containers

test-description: The LTP testsuite contains a collection of tools for testing the Linux kernel and related features.
test-url: http://linux-test-project.github.io/


on test machine: 8 threads Intel(R) Core(TM) i7 CPU 870 @ 2.93GHz with 4G memory

caused below changes (please refer to attached dmesg/kmsg for entire log/backtrace):



2017-05-02 05:31:27 ./runltp -f containers
INFO: creating /lkp/benchmarks/ltp/output directory
INFO: creating /lkp/benchmarks/ltp/results directory
Checking for required user/group ids

'nobody' user id and group found.
'bin' user id and group found.
'daemon' user id and group found.
Users group found.
Sys group found.
Required users/groups exist.
If some fields are empty or look unusual you may have an old version.
Compare to the current minimal requirements in Documentation/Changes.
 
PRETTY_NAME="Debian GNU/Linux stretch/sid"
NAME="Debian GNU/Linux"
ID=debian
HOME_URL="https://www.debian.org/"
SUPPORT_URL="https://www.debian.org/support"
BUG_REPORT_URL="https://bugs.debian.org/"
Linux nhm-white2 4.11.0-rc8-02027-ge445e46 #1 SMP Fri Apr 28 14:39:48 CST 2017 x86_64 GNU/Linux
 
Gnu C                 
util-linux             linux 2.28.1
mount                  mountinfo, assert, debug)
modutils               23
e2fsprogs              1.43.1
Linux C Library        > libc.2.23
Dynamic linker (ldd)   2.23
Procps                 3.3.12
Net-tools              2.10-alpha
iproute2              iproute2-ss161212
Kbd                    69:
Sh-utils               8.25
Modules Loaded         rpcsec_gss_krb5 auth_rpcgss nfsv4 dns_resolver netconsole sr_mod sd_mod cdrom sg snd_hda_codec_realtek ata_generic pata_acpi snd_hda_codec_generic snd_hda_codec_hdmi intel_powerclamp coretemp kvm_intel uas kvm ata_piix irqbypass dcdbas i7core_edac dell_smm_hwmon crc32c_intel pcspkr snd_hda_intel serio_raw edac_core usb_storage libata snd_hda_codec firewire_ohci snd_hda_core firewire_core snd_hwdep crc_itu_t snd_pcm snd_timer snd soundcore shpchp acpi_cpufreq ip_tables broadcom bcm_phy_lib

free reports:
              total        used        free      shared  buff/cache   available
Mem:        4034308      118180     3004756        9020      911372     3685276
Swap:             0           0           0

/proc/cpuinfo
processor	: 0
vendor_id	: GenuineIntel
cpu family	: 6
model		: 30
model name	: Intel(R) Core(TM) i7 CPU         870  @ 2.93GHz
stepping	: 5
microcode	: 0x3
cpu MHz		: 2926.009
cache size	: 8192 KB
physical id	: 0
siblings	: 8
core id		: 0
cpu cores	: 4
apicid		: 0
initial apicid	: 0
fpu		: yes
fpu_exception	: yes
cpuid level	: 11
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf pni dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm sse4_1 sse4_2 popcnt lahf_lm tpr_shadow vnmi flexpriority ept vpid dtherm
bugs		:
bogomips	: 5852.01
clflush size	: 64
cache_alignment	: 64
address sizes	: 36 bits physical, 48 bits virtual
power management:

processor	: 1
vendor_id	: GenuineIntel
cpu family	: 6
model		: 30
model name	: Intel(R) Core(TM) i7 CPU         870  @ 2.93GHz
stepping	: 5
microcode	: 0x3
cpu MHz		: 2926.009
cache size	: 8192 KB
physical id	: 0
siblings	: 8
core id		: 1
cpu cores	: 4
apicid		: 2
initial apicid	: 2
fpu		: yes
fpu_exception	: yes
cpuid level	: 11
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf pni dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm sse4_1 sse4_2 popcnt lahf_lm tpr_shadow vnmi flexpriority ept vpid dtherm
bugs		:
bogomips	: 5850.97
clflush size	: 64
cache_alignment	: 64
address sizes	: 36 bits physical, 48 bits virtual
power management:

processor	: 2
vendor_id	: GenuineIntel
cpu family	: 6
model		: 30
model name	: Intel(R) Core(TM) i7 CPU         870  @ 2.93GHz
stepping	: 5
microcode	: 0x3
cpu MHz		: 2926.009
cache size	: 8192 KB
physical id	: 0
siblings	: 8
core id		: 2
cpu cores	: 4
apicid		: 4
initial apicid	: 4
fpu		: yes
fpu_exception	: yes
cpuid level	: 11
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf pni dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm sse4_1 sse4_2 popcnt lahf_lm tpr_shadow vnmi flexpriority ept vpid dtherm
bugs		:
bogomips	: 5850.98
clflush size	: 64
cache_alignment	: 64
address sizes	: 36 bits physical, 48 bits virtual
power management:

processor	: 3
vendor_id	: GenuineIntel
cpu family	: 6
model		: 30
model name	: Intel(R) Core(TM) i7 CPU         870  @ 2.93GHz
stepping	: 5
microcode	: 0x3
cpu MHz		: 2926.009
cache size	: 8192 KB
physical id	: 0
siblings	: 8
core id		: 3
cpu cores	: 4
apicid		: 6
initial apicid	: 6
fpu		: yes
fpu_exception	: yes
cpuid level	: 11
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf pni dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm sse4_1 sse4_2 popcnt lahf_lm tpr_shadow vnmi flexpriority ept vpid dtherm
bugs		:
bogomips	: 5850.97
clflush size	: 64
cache_alignment	: 64
address sizes	: 36 bits physical, 48 bits virtual
power management:

processor	: 4
vendor_id	: GenuineIntel
cpu family	: 6
model		: 30
model name	: Intel(R) Core(TM) i7 CPU         870  @ 2.93GHz
stepping	: 5
microcode	: 0x3
cpu MHz		: 2926.009
cache size	: 8192 KB
physical id	: 0
siblings	: 8
core id		: 0
cpu cores	: 4
apicid		: 1
initial apicid	: 1
fpu		: yes
fpu_exception	: yes
cpuid level	: 11
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf pni dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm sse4_1 sse4_2 popcnt lahf_lm tpr_shadow vnmi flexpriority ept vpid dtherm
bugs		:
bogomips	: 5850.98
clflush size	: 64
cache_alignment	: 64
address sizes	: 36 bits physical, 48 bits virtual
power management:

processor	: 5
vendor_id	: GenuineIntel
cpu family	: 6
model		: 30
model name	: Intel(R) Core(TM) i7 CPU         870  @ 2.93GHz
stepping	: 5
microcode	: 0x3
cpu MHz		: 2926.009
cache size	: 8192 KB
physical id	: 0
siblings	: 8
core id		: 1
cpu cores	: 4
apicid		: 3
initial apicid	: 3
fpu		: yes
fpu_exception	: yes
cpuid level	: 11
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf pni dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm sse4_1 sse4_2 popcnt lahf_lm tpr_shadow vnmi flexpriority ept vpid dtherm
bugs		:
bogomips	: 5850.97
clflush size	: 64
cache_alignment	: 64
address sizes	: 36 bits physical, 48 bits virtual
power management:

processor	: 6
vendor_id	: GenuineIntel
cpu family	: 6
model		: 30
model name	: Intel(R) Core(TM) i7 CPU         870  @ 2.93GHz
stepping	: 5
microcode	: 0x3
cpu MHz		: 2926.009
cache size	: 8192 KB
physical id	: 0
siblings	: 8
core id		: 2
cpu cores	: 4
apicid		: 5
initial apicid	: 5
fpu		: yes
fpu_exception	: yes
cpuid level	: 11
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf pni dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm sse4_1 sse4_2 popcnt lahf_lm tpr_shadow vnmi flexpriority ept vpid dtherm
bugs		:
bogomips	: 5850.98
clflush size	: 64
cache_alignment	: 64
address sizes	: 36 bits physical, 48 bits virtual
power management:

processor	: 7
vendor_id	: GenuineIntel
cpu family	: 6
model		: 30
model name	: Intel(R) Core(TM) i7 CPU         870  @ 2.93GHz
stepping	: 5
microcode	: 0x3
cpu MHz		: 2926.009
cache size	: 8192 KB
physical id	: 0
siblings	: 8
core id		: 3
cpu cores	: 4
apicid		: 7
initial apicid	: 7
fpu		: yes
fpu_exception	: yes
cpuid level	: 11
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf pni dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm sse4_1 sse4_2 popcnt lahf_lm tpr_shadow vnmi flexpriority ept vpid dtherm
bugs		:
bogomips	: 5850.95
clflush size	: 64
cache_alignment	: 64
address sizes	: 36 bits physical, 48 bits virtual
power management:

no big block device was specified on commandline.
Tests which require a big block device are disabled.
You can specify it with option -z
COMMAND:    /lkp/benchmarks/ltp/bin/ltp-pan  -e -S   -a 9542     -n 9542  -p  -f /tmp/ltp-zhbiygX3Vt/alltests -l /lkp/benchmarks/ltp/results/LTP_RUN_ON-2017_05_02-05h_31m_27s.log  -C /lkp/benchmarks/ltp/output/LTP_RUN_ON-2017_05_02-05h_31m_27s.failed -T /lkp/benchmarks/ltp/output/LTP_RUN_ON-2017_05_02-05h_31m_27s.tconf
LOG File: /lkp/benchmarks/ltp/results/LTP_RUN_ON-2017_05_02-05h_31m_27s.log
FAILED COMMAND File: /lkp/benchmarks/ltp/output/LTP_RUN_ON-2017_05_02-05h_31m_27s.failed
TCONF COMMAND File: /lkp/benchmarks/ltp/output/LTP_RUN_ON-2017_05_02-05h_31m_27s.tconf
Running tests.......
<<<test_start>>>
tag=pidns01 stime=1493674288
cmdline="pidns01"
contacts=""
analysis=exit
<<<test_output>>>
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pidns02 stime=1493674288
cmdline="pidns02"
contacts=""
analysis=exit
<<<test_output>>>
Checking session id & group id inside container
Success: Got Group ID = 1 & Session ID = 1
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pidns03 stime=1493674288
cmdline="pidns03"
contacts=""
analysis=exit
<<<test_output>>>
pidns03     1  TPASS  :  mounting procfs in a new namespace
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pidns04 stime=1493674288
cmdline="pidns04"
contacts=""
analysis=exit
<<<test_output>>>
PIDNS test is running inside container
pidns04     1  TPASS  :  Container init : I was not killed !
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pidns05 stime=1493674288
cmdline="pidns05"
contacts=""
analysis=exit
<<<test_output>>>
pidns05     0  TINFO  :   5 Nested Containers are created
pidns05     1  TPASS  :  The number of containers killed are 2
<<<execution_status>>>
initiation_status="ok"
duration=1 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pidns06 stime=1493674289
cmdline="pidns06"
contacts=""
analysis=exit
<<<test_output>>>
pidns06     0  TINFO  :  Parent: Passing the pid of the process 9691
Container: killing parent pid=9691 failed as expected with ESRCH
Container: killing non-existent pid failed as expected with ESRCH
pidns06     0  TINFO  :  Parent: Passing the pid of the process 9691
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pidns10 stime=1493674289
cmdline="pidns10"
contacts=""
analysis=exit
<<<test_output>>>
cinit: kill(-1, sig) failed with -1 / ESRCH as expected
<<<execution_status>>>
initiation_status="ok"
duration=1 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pidns12 stime=1493674290
cmdline="pidns12"
contacts=""
analysis=exit
<<<test_output>>>
pidns12     0  TINFO  :  parent: PID is 9697
pidns12     1  TPASS  :  cinit: signalling PID (from other namespace) is 0 as expected
pidns12     0  TINFO  :  parent: PID is 9697
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pidns13 stime=1493674290
cmdline="pidns13"
contacts=""
analysis=exit
<<<test_output>>>
pidns13     0  TINFO  :  cinit2: writing some data in pipe
pidns13     0  TINFO  :  cinit1: setup handler for async I/O on pipe
pidns13     1  TPASS  :  cinit1: si_fd is 7, si_code is 1
<<<execution_status>>>
initiation_status="ok"
duration=2 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pidns16 stime=1493674292
cmdline="pidns16"
contacts=""
analysis=exit
<<<test_output>>>
pidns16     1  TPASS  :  container init continued successfuly, after handling signal -USR1
<<<execution_status>>>
initiation_status="ok"
duration=2 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pidns17 stime=1493674294
cmdline="pidns17"
contacts=""
analysis=exit
<<<test_output>>>
cinit: all children have terminated.
<<<execution_status>>>
initiation_status="ok"
duration=1 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pidns20 stime=1493674295
cmdline="pidns20"
contacts=""
analysis=exit
<<<test_output>>>
pidns20     0  TINFO  :  cinit: blocked SIGUSR1
pidns20     0  TINFO  :  cinit: unblocking SIGUSR1
pidns20     1  TPASS  :  cinit: user function is called as expected
pidns20     0  TINFO  :  parent: signalled SIGUSR1 to container
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=1 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pidns30 stime=1493674295
cmdline="pidns30"
contacts=""
analysis=exit
<<<test_output>>>
mq_open succeeded
successfully registered for notification
successfully registered handler for SIGUSR1
signal originator PID = 0
parent is done - cleaning up
pidns30     0  TINFO  :  successfully created posix mqueue
pidns30     0  TINFO  :  mq_send succeeded
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pidns31 stime=1493674295
cmdline="pidns31"
contacts=""
analysis=exit
<<<test_output>>>
pidns31     0  TINFO  :  parent: successfully created posix mqueue
pidns31     0  TINFO  :  cinit: my father is ready to receive a message
pidns31     0  TINFO  :  cinit: mq_open succeeded
pidns31     0  TINFO  :  cinit: mq_send() succeeded
pidns31     0  TINFO  :  parent: successfully created posix mqueue
pidns31     0  TINFO  :  parent: successfully created child (pid = 9728)
pidns31     0  TINFO  :  parent: successfully registered for notification
pidns31     0  TINFO  :  parent: successfully registered handler for SIGUSR1
pidns31     1  TPASS  :  father: signal originator PID = 9728
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pidns32 stime=1493674295
cmdline="pidns32"
contacts=""
analysis=exit
<<<test_output>>>
pidns32     0  TINFO  :  Child process returned TPASS
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=mqns_01 stime=1493674295
cmdline="mqns_01"
contacts=""
analysis=exit
<<<test_output>>>
posixmq_namespace_01    0  TINFO  :  Testing posix mq namespaces through unshare(2).
posixmq_namespace_01    0  TINFO  :  Checking namespaces isolation from parent to child
posixmq_namespace_01    1  TPASS  :  child process didn't find mqueue
posixmq_namespace_01    0  TINFO  :  Testing posix mq namespaces through unshare(2).
posixmq_namespace_01    0  TINFO  :  Checking namespaces isolation from parent to child
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mqns_01_clone stime=1493674295
cmdline="mqns_01 -clone"
contacts=""
analysis=exit
<<<test_output>>>
posixmq_namespace_01    0  TINFO  :  Testing posix mq namespaces through clone(2).
posixmq_namespace_01    0  TINFO  :  Checking namespaces isolation from parent to child
posixmq_namespace_01    0  TINFO  :  Testing posix mq namespaces through clone(2).
posixmq_namespace_01    0  TINFO  :  Checking namespaces isolation from parent to child
posixmq_namespace_01    1  TPASS  :  child process didn't find mqueue
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mqns_02 stime=1493674295
cmdline="mqns_02"
contacts=""
analysis=exit
<<<test_output>>>
posixmq_namespace_02    0  TINFO  :  Testing posix mq namespaces through unshare(2).
posixmq_namespace_02    0  TINFO  :  Checking namespaces isolation (child to parent)
posixmq_namespace_02    1  TPASS  :  Parent process can't see the mqueue
posixmq_namespace_02    0  TINFO  :  Testing posix mq namespaces through unshare(2).
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mqns_02_clone stime=1493674295
cmdline="mqns_02 -clone"
contacts=""
analysis=exit
<<<test_output>>>
posixmq_namespace_02    0  TINFO  :  Testing posix mq namespaces through clone(2).
posixmq_namespace_02    0  TINFO  :  Testing posix mq namespaces through clone(2).
posixmq_namespace_02    0  TINFO  :  Checking namespaces isolation (child to parent)
posixmq_namespace_02    1  TPASS  :  Parent process can't see the mqueue
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mqns_03 stime=1493674295
cmdline="mqns_03"
contacts=""
analysis=exit
<<<test_output>>>
posixmq_namespace_03    0  TINFO  :  Testing posix mq namespaces through unshare(2)
posixmq_namespace_03    0  TINFO  :  Testing posix mq namespaces through unshare(2)
posixmq_namespace_03    0  TINFO  :  Checking correct umount+remount of mqueuefs
posixmq_namespace_03    1  TPASS  :  umount+remount of mqueuefs remounted the right fs
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mqns_03_clone stime=1493674295
cmdline="mqns_03 -clone"
contacts=""
analysis=exit
<<<test_output>>>
posixmq_namespace_03    0  TINFO  :  Testing posix mq namespaces through clone(2)
posixmq_namespace_03    0  TINFO  :  Testing posix mq namespaces through clone(2)
posixmq_namespace_03    0  TINFO  :  Checking correct umount+remount of mqueuefs
posixmq_namespace_03    1  TPASS  :  umount+remount of mqueuefs remounted the right fs
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=1 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mqns_04 stime=1493674295
cmdline="mqns_04"
contacts=""
analysis=exit
<<<test_output>>>
posixmq_namespace_04    0  TINFO  :  Testing posix mq namespaces through unshare(2).
posixmq_namespace_04    0  TINFO  :  Checking mqueue filesystem lifetime
posixmq_namespace_04    0  TINFO  :  Testing posix mq namespaces through unshare(2).
posixmq_namespace_04    0  TINFO  :  Checking mqueue filesystem lifetime
posixmq_namespace_04    1  TPASS  :  Child mqueue fs still visible for parent
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mqns_04_clone stime=1493674295
cmdline="mqns_04 -clone"
contacts=""
analysis=exit
<<<test_output>>>
posixmq_namespace_04    0  TINFO  :  Testing posix mq namespaces through clone(2).
posixmq_namespace_04    0  TINFO  :  Checking mqueue filesystem lifetime
posixmq_namespace_04    0  TINFO  :  Testing posix mq namespaces through clone(2).
posixmq_namespace_04    0  TINFO  :  Checking mqueue filesystem lifetime
posixmq_namespace_04    1  TPASS  :  Child mqueue fs still visible for parent
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=netns_netlink stime=1493674295
cmdline="netns_netlink"
contacts=""
analysis=exit
<<<test_output>>>
netns_netlink    1  TPASS  :  netlink interface pass
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=netns_breakns_ns_exec_ipv4_netlink stime=1493674295
cmdline="netns_breakns.sh ns_exec ipv4 netlink"
contacts=""
analysis=exit
<<<test_output>>>
netns_breakns_ns_exec_ipv4_netlink 1 TINFO : NS interaction: ns_exec | devices setup: netlink
netns_breakns_ns_exec_ipv4_netlink 1 TPASS : controlling device over netlink
netns_breakns_ns_exec_ipv4_netlink 2 TPASS : controlling device over ioctl
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=2 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=netns_breakns_ns_exec_ipv6_netlink stime=1493674295
cmdline="netns_breakns.sh ns_exec ipv6 netlink"
contacts=""
analysis=exit
<<<test_output>>>
netns_breakns_ns_exec_ipv6_netlink 1 TINFO : NS interaction: ns_exec | devices setup: netlink
netns_breakns_ns_exec_ipv6_netlink 1 TPASS : controlling device over netlink
netns_breakns_ns_exec_ipv6_netlink 2 TPASS : controlling device over ioctl
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=1 cstime=2
<<<test_end>>>
<<<test_start>>>
tag=netns_breakns_ns_exec_ipv4_ioctl stime=1493674295
cmdline="netns_breakns.sh ns_exec ipv4 ioctl"
contacts=""
analysis=exit
<<<test_output>>>
netns_breakns_ns_exec_ipv4_ioctl 1 TINFO : NS interaction: ns_exec | devices setup: ioctl
netns_breakns_ns_exec_ipv4_ioctl 1 TPASS : controlling device over netlink
netns_breakns_ns_exec_ipv4_ioctl 2 TPASS : controlling device over ioctl
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=1 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=netns_breakns_ns_exec_ipv6_ioctl stime=1493674295
cmdline="netns_breakns.sh ns_exec ipv6 ioctl"
contacts=""
analysis=exit
<<<test_output>>>
netns_breakns_ns_exec_ipv6_ioctl 1 TINFO : NS interaction: ns_exec | devices setup: ioctl
netns_breakns_ns_exec_ipv6_ioctl 1 TPASS : controlling device over netlink
netns_breakns_ns_exec_ipv6_ioctl 2 TPASS : controlling device over ioctl
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=2 cstime=2
<<<test_end>>>
<<<test_start>>>
tag=netns_breakns_ip_ipv4_netlink stime=1493674295
cmdline="netns_breakns.sh ip ipv4 netlink"
contacts=""
analysis=exit
<<<test_output>>>
netns_breakns_ip_ipv4_netlink 1 TINFO : NS interaction: ip | devices setup: netlink
netns_breakns_ip_ipv4_netlink 1 TPASS : controlling device over netlink
netns_breakns_ip_ipv4_netlink 2 TPASS : controlling device over ioctl
<<<execution_status>>>
initiation_status="ok"
duration=1 termination_type=exited termination_id=0 corefile=no
cutime=1 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=netns_breakns_ip_ipv6_netlink stime=1493674296
cmdline="netns_breakns.sh ip ipv6 netlink"
contacts=""
analysis=exit
<<<test_output>>>
netns_breakns_ip_ipv6_netlink 1 TINFO : NS interaction: ip | devices setup: netlink
netns_breakns_ip_ipv6_netlink 1 TPASS : controlling device over netlink
netns_breakns_ip_ipv6_netlink 2 TPASS : controlling device over ioctl
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=2 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=netns_breakns_ip_ipv4_ioctl stime=1493674296
cmdline="netns_breakns.sh ip ipv4 ioctl"
contacts=""
analysis=exit
<<<test_output>>>
netns_breakns_ip_ipv4_ioctl 1 TINFO : NS interaction: ip | devices setup: ioctl
netns_breakns_ip_ipv4_ioctl 1 TPASS : controlling device over netlink
netns_breakns_ip_ipv4_ioctl 2 TPASS : controlling device over ioctl
<<<execution_status>>>
initiation_status="ok"
duration=1 termination_type=exited termination_id=0 corefile=no
cutime=2 cstime=2
<<<test_end>>>
<<<test_start>>>
tag=netns_breakns_ip_ipv6_ioctl stime=1493674297
cmdline="netns_breakns.sh ip ipv6 ioctl"
contacts=""
analysis=exit
<<<test_output>>>
netns_breakns_ip_ipv6_ioctl 1 TINFO : NS interaction: ip | devices setup: ioctl
netns_breakns_ip_ipv6_ioctl 1 TPASS : controlling device over netlink
netns_breakns_ip_ipv6_ioctl 2 TPASS : controlling device over ioctl
<<<execution_status>>>
initiation_status="ok"
duration=1 termination_type=exited termination_id=0 corefile=no
cutime=1 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=netns_comm_ns_exec_ipv4_netlink stime=1493674298
cmdline="netns_comm.sh ns_exec ipv4 netlink"
contacts=""
analysis=exit
<<<test_output>>>
netns_comm_ns_exec_ipv4_netlink 1 TINFO : NS interaction: ns_exec | devices setup: netlink
netns_comm_ns_exec_ipv4_netlink 1 TPASS : configuration and communication over veth0
netns_comm_ns_exec_ipv4_netlink 2 TPASS : configuration and communication over veth1
netns_comm_ns_exec_ipv4_netlink 3 TPASS : configuration and communication over localhost
<<<execution_status>>>
initiation_status="ok"
duration=3 termination_type=exited termination_id=0 corefile=no
cutime=2 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=netns_comm_ns_exec_ipv6_netlink stime=1493674301
cmdline="netns_comm.sh ns_exec ipv6 netlink"
contacts=""
analysis=exit
<<<test_output>>>
netns_comm_ns_exec_ipv6_netlink 1 TINFO : NS interaction: ns_exec | devices setup: netlink
netns_comm_ns_exec_ipv6_netlink 1 TFAIL : configuration and communication over veth0
netns_comm_ns_exec_ipv6_netlink 2 TFAIL : configuration and communication over veth1
netns_comm_ns_exec_ipv6_netlink 3 TPASS : configuration and communication over localhost
<<<execution_status>>>
initiation_status="ok"
duration=23 termination_type=exited termination_id=1 corefile=no
cutime=2 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=netns_comm_ns_exec_ipv4_ioctl stime=1493674324
cmdline="netns_comm.sh ns_exec ipv4 ioctl"
contacts=""
analysis=exit
<<<test_output>>>
netns_comm_ns_exec_ipv4_ioctl 1 TINFO : NS interaction: ns_exec | devices setup: ioctl
netns_comm_ns_exec_ipv4_ioctl 1 TPASS : configuration and communication over veth0
netns_comm_ns_exec_ipv4_ioctl 2 TPASS : configuration and communication over veth1
netns_comm_ns_exec_ipv4_ioctl 3 TPASS : configuration and communication over localhost
<<<execution_status>>>
initiation_status="ok"
duration=3 termination_type=exited termination_id=0 corefile=no
cutime=1 cstime=2
<<<test_end>>>
<<<test_start>>>
tag=netns_comm_ns_exec_ipv6_ioctl stime=1493674327
cmdline="netns_comm.sh ns_exec ipv6 ioctl"
contacts=""
analysis=exit
<<<test_output>>>
netns_comm_ns_exec_ipv6_ioctl 1 TINFO : NS interaction: ns_exec | devices setup: ioctl
netns_comm_ns_exec_ipv6_ioctl 1 TFAIL : configuration and communication over veth0
netns_comm_ns_exec_ipv6_ioctl 2 TFAIL : configuration and communication over veth1
netns_comm_ns_exec_ipv6_ioctl 3 TPASS : configuration and communication over localhost
<<<execution_status>>>
initiation_status="ok"
duration=23 termination_type=exited termination_id=1 corefile=no
cutime=2 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=netns_comm_ip_ipv4_netlink stime=1493674350
cmdline="netns_comm.sh ip ipv4 netlink"
contacts=""
analysis=exit
<<<test_output>>>
netns_comm_ip_ipv4_netlink 1 TINFO : NS interaction: ip | devices setup: netlink
netns_comm_ip_ipv4_netlink 1 TPASS : configuration and communication over veth0
netns_comm_ip_ipv4_netlink 2 TPASS : configuration and communication over veth1
netns_comm_ip_ipv4_netlink 3 TPASS : configuration and communication over localhost
<<<execution_status>>>
initiation_status="ok"
duration=4 termination_type=exited termination_id=0 corefile=no
cutime=1 cstime=2
<<<test_end>>>
<<<test_start>>>
tag=netns_comm_ip_ipv6_netlink stime=1493674354
cmdline="netns_comm.sh ip ipv6 netlink"
contacts=""
analysis=exit
<<<test_output>>>
netns_comm_ip_ipv6_netlink 1 TINFO : NS interaction: ip | devices setup: netlink
netns_comm_ip_ipv6_netlink 1 TFAIL : configuration and communication over veth0
netns_comm_ip_ipv6_netlink 2 TFAIL : configuration and communication over veth1
netns_comm_ip_ipv6_netlink 3 TPASS : configuration and communication over localhost
<<<execution_status>>>
initiation_status="ok"
duration=23 termination_type=exited termination_id=1 corefile=no
cutime=1 cstime=2
<<<test_end>>>
<<<test_start>>>
tag=netns_comm_ip_ipv4_ioctl stime=1493674377
cmdline="netns_comm.sh ip ipv4 ioctl"
contacts=""
analysis=exit
<<<test_output>>>
netns_comm_ip_ipv4_ioctl 1 TINFO : NS interaction: ip | devices setup: ioctl
netns_comm_ip_ipv4_ioctl 1 TPASS : configuration and communication over veth0
netns_comm_ip_ipv4_ioctl 2 TPASS : configuration and communication over veth1
netns_comm_ip_ipv4_ioctl 3 TPASS : configuration and communication over localhost
<<<execution_status>>>
initiation_status="ok"
duration=4 termination_type=exited termination_id=0 corefile=no
cutime=2 cstime=2
<<<test_end>>>
<<<test_start>>>
tag=netns_comm_ip_ipv6_ioctl stime=1493674381
cmdline="netns_comm.sh ip ipv6 ioctl"
contacts=""
analysis=exit
<<<test_output>>>
netns_comm_ip_ipv6_ioctl 1 TINFO : NS interaction: ip | devices setup: ioctl
netns_comm_ip_ipv6_ioctl 1 TFAIL : configuration and communication over veth0
netns_comm_ip_ipv6_ioctl 2 TFAIL : configuration and communication over veth1
netns_comm_ip_ipv6_ioctl 3 TPASS : configuration and communication over localhost
<<<execution_status>>>
initiation_status="ok"
duration=23 termination_type=exited termination_id=1 corefile=no
cutime=2 cstime=2
<<<test_end>>>
<<<test_start>>>
tag=netns_sysfs stime=1493674404
cmdline="netns_sysfs.sh"
contacts=""
analysis=exit
<<<test_output>>>
netns_sysfs 1 TPASS : sysfs in new namespace has dummy_test1 interface
netns_sysfs 2 TPASS : sysfs in new namespace does not have dummy_test0 interface
netns_sysfs 3 TPASS : sysfs not affected by a separate namespace
<<<execution_status>>>
initiation_status="ok"
duration=1 termination_type=exited termination_id=0 corefile=no
cutime=1 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=shmnstest_none stime=1493674405
cmdline="shmnstest none"
contacts=""
analysis=exit
<<<test_output>>>
sysvipc_namespace    0  TINFO  :  shmid namespaces test : none
sysvipc_namespace    0  TINFO  :  shmid namespaces test : none
sysvipc_namespace    1  TPASS  :  plain cloned process found shmid
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=shmnstest_clone stime=1493674405
cmdline="shmnstest clone"
contacts=""
analysis=exit
<<<test_output>>>
sysvipc_namespace    0  TINFO  :  shmid namespaces test : clone
sysvipc_namespace    0  TINFO  :  shmid namespaces test : clone
sysvipc_namespace    1  TPASS  :  clone: child process didn't find shmid
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=shmnstest_unshare stime=1493674405
cmdline="shmnstest unshare"
contacts=""
analysis=exit
<<<test_output>>>
sysvipc_namespace    0  TINFO  :  shmid namespaces test : unshare
sysvipc_namespace    0  TINFO  :  shmid namespaces test : unshare
sysvipc_namespace    1  TPASS  :  unshare: child process didn't find shmid
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=shmem_2nstest_none stime=1493674405
cmdline="shmem_2nstest none"
contacts=""
analysis=exit
<<<test_output>>>
shmem_2nstest    0  TINFO  :  Shared Memory namespace test : none
shmem_2nstest    0  TINFO  :  Cont1: Able to create shared mem segment
shmem_2nstest    0  TINFO  :  Shared Memory namespace test : none
shmem_2nstest    0  TINFO  :  Shared Memory namespace test : none
shmem_2nstest    1  TPASS  :  Plain cloned process able to access shmem segment created
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=shmem_2nstest_clone stime=1493674405
cmdline="shmem_2nstest clone"
contacts=""
analysis=exit
<<<test_output>>>
shmem_2nstest    0  TINFO  :  Shared Memory namespace test : clone
shmem_2nstest    0  TINFO  :  Cont1: Able to create shared mem segment
shmem_2nstest    0  TINFO  :  Shared Memory namespace test : clone
shmem_2nstest    0  TINFO  :  Cont2: Able to allocate shmem seg with the same key
shmem_2nstest    0  TINFO  :  Shared Memory namespace test : clone
shmem_2nstest    1  TPASS  :  clone : In namespace2 unable to access the shmem seg created in Namespace1
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=shmem_2nstest_unshare stime=1493674405
cmdline="shmem_2nstest unshare"
contacts=""
analysis=exit
<<<test_output>>>
shmem_2nstest    0  TINFO  :  Shared Memory namespace test : unshare
shmem_2nstest    0  TINFO  :  Cont1: Able to create shared mem segment
shmem_2nstest    0  TINFO  :  Shared Memory namespace test : unshare
shmem_2nstest    0  TINFO  :  Cont2: Able to allocate shmem seg with the same key
shmem_2nstest    0  TINFO  :  Shared Memory namespace test : unshare
shmem_2nstest    1  TPASS  :  unshare : In namespace2 unable to access the shmem seg created in Namespace1
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=shm_comm stime=1493674405
cmdline="shm_comm"
contacts=""
analysis=exit
<<<test_output>>>
shm_comm    1  TPASS  :  SysV shm: communication with identical keys between namespaces
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mesgq_nstest_none stime=1493674405
cmdline="mesgq_nstest none"
contacts=""
analysis=exit
<<<test_output>>>
mesgq_nstest    0  TINFO  :  mesgq namespaces test : none
mesgq_nstest    0  TINFO  :  Mesg read of 18 bytes; Type 5: Msg: Message of type 5!
mesgq_nstest    0  TINFO  :  mesgq namespaces test : none
mesgq_nstest    1  TPASS  :  Plain cloned process found mesgq inside container
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=mesgq_nstest_clone stime=1493674405
cmdline="mesgq_nstest clone"
contacts=""
analysis=exit
<<<test_output>>>
mesgq_nstest    0  TINFO  :  mesgq namespaces test : clone
mesgq_nstest    0  TINFO  :  mesgq namespaces test : clone
mesgq_nstest    1  TPASS  :  clone: Container didn't find mesgq
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mesgq_nstest_unshare stime=1493674405
cmdline="mesgq_nstest unshare"
contacts=""
analysis=exit
<<<test_output>>>
mesgq_nstest    0  TINFO  :  mesgq namespaces test : unshare
mesgq_nstest    0  TINFO  :  mesgq namespaces test : unshare
mesgq_nstest    1  TPASS  :  unshare: Container didn't find mesgq
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=msg_comm stime=1493674405
cmdline="msg_comm"
contacts=""
analysis=exit
<<<test_output>>>
msg_comm    1  TPASS  :  SysV msg: communication with identical keys between namespaces
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sem_nstest_none stime=1493674405
cmdline="sem_nstest none"
contacts=""
analysis=exit
<<<test_output>>>
sem_nstest    0  TINFO  :  Semaphore namespaces Isolation test : none
sem_nstest    0  TINFO  :  PID 10464: Fetched existing semaphore..id = 32769
sem_nstest    0  TINFO  :  Semaphore namespaces Isolation test : none
sem_nstest    1  TPASS  :  Plain cloned process found semaphore inside container
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sem_nstest_clone stime=1493674405
cmdline="sem_nstest clone"
contacts=""
analysis=exit
<<<test_output>>>
sem_nstest    0  TINFO  :  Semaphore namespaces Isolation test : clone
sem_nstest    0  TINFO  :  Semaphore namespaces Isolation test : clone
sem_nstest    1  TPASS  :  clone: Container didn't find semaphore
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sem_nstest_unshare stime=1493674405
cmdline="sem_nstest unshare"
contacts=""
analysis=exit
<<<test_output>>>
sem_nstest    0  TINFO  :  Semaphore namespaces Isolation test : unshare
sem_nstest    0  TINFO  :  Semaphore namespaces Isolation test : unshare
sem_nstest    1  TPASS  :  unshare: Container didn't find semaphore
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=semtest_2ns_none stime=1493674405
cmdline="semtest_2ns none"
contacts=""
analysis=exit
<<<test_output>>>
semtest_2ns    0  TINFO  :  Semaphore Namespaces Test : none
semtest_2ns    0  TINFO  :  Cont1: Able to create semaphore
semtest_2ns    0  TINFO  :  Semaphore Namespaces Test : none
semtest_2ns    0  TINFO  :  Sem1: File locked, Critical section is updated...
semtest_2ns    0  TINFO  :  Semaphore Namespaces Test : none
semtest_2ns    1  TPASS  :  Plain cloned process able to access the semaphore created
<<<execution_status>>>
initiation_status="ok"
duration=2 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=semtest_2ns_clone stime=1493674407
cmdline="semtest_2ns clone"
contacts=""
analysis=exit
<<<test_output>>>
semtest_2ns    0  TINFO  :  Semaphore Namespaces Test : clone
semtest_2ns    0  TINFO  :  Cont1: Able to create semaphore
semtest_2ns    0  TINFO  :  Semaphore Namespaces Test : clone
semtest_2ns    0  TINFO  :  Cont2: Able to create semaphore with sameKey
semtest_2ns    0  TINFO  :  Semaphore Namespaces Test : clone
semtest_2ns    1  TPASS  :  clone : In namespace2 unable to access the semaphore created in Namespace1
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=semtest_2ns_unshare stime=1493674407
cmdline="semtest_2ns unshare"
contacts=""
analysis=exit
<<<test_output>>>
semtest_2ns    0  TINFO  :  Semaphore Namespaces Test : unshare
semtest_2ns    0  TINFO  :  Cont1: Able to create semaphore
semtest_2ns    0  TINFO  :  Semaphore Namespaces Test : unshare
semtest_2ns    0  TINFO  :  Cont2: Able to create semaphore with sameKey
semtest_2ns    0  TINFO  :  Semaphore Namespaces Test : unshare
semtest_2ns    1  TPASS  :  unshare : In namespace2 unable to access the semaphore created in Namespace1
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sem_comm stime=1493674407
cmdline="sem_comm"
contacts=""
analysis=exit
<<<test_output>>>
sem_comm    1  TPASS  :  SysV sem: communication with identical keys between namespaces
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=1 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=utstest_unshare_1 stime=1493674407
cmdline="utstest unshare 1"
contacts=""
analysis=exit
<<<test_output>>>
uts_namespace    1  TPASS  :  test 1 (unshare): success
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=utstest_unshare_2 stime=1493674407
cmdline="utstest unshare 2"
contacts=""
analysis=exit
<<<test_output>>>
uts_namespace    1  TPASS  :  test 2 (unshare): success
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=utstest_unshare_3 stime=1493674407
cmdline="utstest unshare 3"
contacts=""
analysis=exit
<<<test_output>>>
uts_namespace    1  TPASS  :  test 3 (unshare): success
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=utstest_unshare_4 stime=1493674407
cmdline="utstest unshare 4"
contacts=""
analysis=exit
<<<test_output>>>
uts_namespace    1  TPASS  :  test 4 (unshare): successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=utstest_unshare_5 stime=1493674407
cmdline="utstest unshare 5"
contacts=""
analysis=exit
<<<test_output>>>
uts_namespace    1  TPASS  :  P2: P1 claims error
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=utstest_clone_1 stime=1493674407
cmdline="utstest clone 1"
contacts=""
analysis=exit
<<<test_output>>>
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=utstest_clone_2 stime=1493674407
cmdline="utstest clone 2"
contacts=""
analysis=exit
<<<test_output>>>
uts_namespace    1  TPASS  :  test 2 (clone): success
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=utstest_clone_3 stime=1493674407
cmdline="utstest clone 3"
contacts=""
analysis=exit
<<<test_output>>>
uts_namespace    1  TPASS  :  test 3 (clone): success
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=utstest_clone_4 stime=1493674407
cmdline="utstest clone 4"
contacts=""
analysis=exit
<<<test_output>>>
uts_namespace    1  TPASS  :  test 4 (clone): successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=utstest_clone_5 stime=1493674407
cmdline="utstest clone 5"
contacts=""
analysis=exit
<<<test_output>>>
uts_namespace    1  TPASS  :  P2: P1 claims error
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mountns01 stime=1493674407
cmdline="mountns01"
contacts=""
analysis=exit
<<<test_output>>>
mountns01    1  TPASS  :  shared mount in child passed
mountns01    2  TPASS  :  shared mount in parent passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mountns02 stime=1493674407
cmdline="mountns02"
contacts=""
analysis=exit
<<<test_output>>>
mountns02    1  TPASS  :  private mount in child passed
mountns02    2  TPASS  :  private mount in parent passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mountns03 stime=1493674407
cmdline="mountns03"
contacts=""
analysis=exit
<<<test_output>>>
mountns03    1  TPASS  :  propagation from slave mount passed
mountns03    2  TPASS  :  propagation to slave mount passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mountns04 stime=1493674407
cmdline="mountns04"
contacts=""
analysis=exit
<<<test_output>>>
mountns04    1  TPASS  :  unbindable mount passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=1 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=userns01 stime=1493674407
cmdline="userns01"
contacts=""
analysis=exit
<<<test_output>>>
user_namespace1    0  TINFO  :  Child process returned TPASS
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=userns02 stime=1493674407
cmdline="userns02"
contacts=""
analysis=exit
<<<test_output>>>
user_namespace2    0  TINFO  :  Child process returned TPASS
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=userns03 stime=1493674407
cmdline="userns03"
contacts=""
analysis=exit
<<<test_output>>>
user_namespace3    1  TPASS  :  setgroups can't be re-enabled
user_namespace3    0  TINFO  :  Child process returned TPASS
user_namespace3    0  TINFO  :  Child process returned TPASS
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=userns04 stime=1493674407
cmdline="userns04"
contacts=""
analysis=exit
<<<test_output>>>
user_namespace4    0  TINFO  :  Child process returned TPASS
user_namespace4    0  TINFO  :  Child process returned TPASS
user_namespace4    0  TINFO  :  Child process returned TPASS
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=userns05 stime=1493674407
cmdline="userns05"
contacts=""
analysis=exit
<<<test_output>>>
user_namespace5    0  TINFO  :  Child process returned TPASS
user_namespace5    0  TINFO  :  Child process returned TPASS
user_namespace5    0  TINFO  :  Child process returned TPASS
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=userns06 stime=1493674407
cmdline="userns06"
contacts=""
analysis=exit
<<<test_output>>>
user_namespace6    0  TINFO  :  Child process returned TPASS
user_namespace6    0  TINFO  :  Child process returned TPASS
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=userns07 stime=1493674407
cmdline="userns07"
contacts=""
analysis=exit
<<<test_output>>>
userns07    0  TINFO  :  Child process returned TPASS
incrementing stop
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=1 cstime=1
<<<test_end>>>
INFO: ltp-pan reported some tests FAIL
LTP Version: 20160920-191-g8cc4165e2

       ###############################################################

            Done executing testcases.
            LTP Version:  20160920-191-g8cc4165e2
       ###############################################################




To reproduce:

        git clone https://github.com/01org/lkp-tests.git
        cd lkp-tests
        bin/lkp install job.yaml  # job file is attached in this email
        bin/lkp run     job.yaml



Thanks,
Xiaolong

--Q0rSlbzrZN6k9QnT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-4.11.0-rc8-02027-ge445e46"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 4.11.0-rc8 Kernel Configuration
#
CONFIG_64BIT=y
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf64-x86-64"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_MMU=y
CONFIG_ARCH_MMAP_RND_BITS_MIN=28
CONFIG_ARCH_MMAP_RND_BITS_MAX=32
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MIN=8
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MAX=16
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ARCH_WANT_HUGE_PMD_SHARE=y
CONFIG_ARCH_WANT_GENERAL_HUGETLB=y
CONFIG_ZONE_DMA32=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_HAVE_INTEL_TXT=y
CONFIG_X86_64_SMP=y
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_PGTABLE_LEVELS=4
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y
CONFIG_THREAD_INFO_IN_TASK=y

#
# General setup
#
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
# CONFIG_COMPILE_TEST is not set
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_HAVE_KERNEL_LZ4=y
CONFIG_KERNEL_GZIP=y
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
CONFIG_POSIX_MQUEUE=y
CONFIG_POSIX_MQUEUE_SYSCTL=y
CONFIG_CROSS_MEMORY_ATTACH=y
CONFIG_FHANDLE=y
CONFIG_USELIB=y
CONFIG_AUDIT=y
CONFIG_HAVE_ARCH_AUDITSYSCALL=y
CONFIG_AUDITSYSCALL=y
CONFIG_AUDIT_WATCH=y
CONFIG_AUDIT_TREE=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_DOMAIN_HIERARCHY=y
CONFIG_GENERIC_MSI_IRQ=y
CONFIG_GENERIC_MSI_IRQ_DOMAIN=y
# CONFIG_IRQ_DOMAIN_DEBUG is not set
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
CONFIG_CLOCKSOURCE_VALIDATE_LAST_CYCLE=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
CONFIG_GENERIC_CMOS_UPDATE=y

#
# Timers subsystem
#
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ_COMMON=y
# CONFIG_HZ_PERIODIC is not set
# CONFIG_NO_HZ_IDLE is not set
CONFIG_NO_HZ_FULL=y
# CONFIG_NO_HZ_FULL_ALL is not set
# CONFIG_NO_HZ_FULL_SYSIDLE is not set
CONFIG_NO_HZ=y
CONFIG_HIGH_RES_TIMERS=y

#
# CPU/Task time and stats accounting
#
CONFIG_VIRT_CPU_ACCOUNTING=y
CONFIG_VIRT_CPU_ACCOUNTING_GEN=y
# CONFIG_IRQ_TIME_ACCOUNTING is not set
CONFIG_BSD_PROCESS_ACCT=y
CONFIG_BSD_PROCESS_ACCT_V3=y
CONFIG_TASKSTATS=y
CONFIG_TASK_DELAY_ACCT=y
CONFIG_TASK_XACCT=y
CONFIG_TASK_IO_ACCOUNTING=y

#
# RCU Subsystem
#
CONFIG_TREE_RCU=y
# CONFIG_RCU_EXPERT is not set
CONFIG_SRCU=y
CONFIG_TASKS_RCU=y
CONFIG_RCU_STALL_COMMON=y
CONFIG_CONTEXT_TRACKING=y
# CONFIG_CONTEXT_TRACKING_FORCE is not set
# CONFIG_TREE_RCU_TRACE is not set
CONFIG_RCU_NOCB_CPU=y
# CONFIG_RCU_NOCB_CPU_NONE is not set
# CONFIG_RCU_NOCB_CPU_ZERO is not set
CONFIG_RCU_NOCB_CPU_ALL=y
CONFIG_BUILD_BIN2C=y
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=19
CONFIG_LOG_CPU_MAX_BUF_SHIFT=12
CONFIG_PRINTK_SAFE_LOG_BUF_SHIFT=13
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH=y
CONFIG_ARCH_SUPPORTS_INT128=y
CONFIG_NUMA_BALANCING=y
CONFIG_NUMA_BALANCING_DEFAULT_ENABLED=y
CONFIG_CGROUPS=y
CONFIG_PAGE_COUNTER=y
CONFIG_MEMCG=y
CONFIG_MEMCG_SWAP=y
CONFIG_MEMCG_SWAP_ENABLED=y
CONFIG_BLK_CGROUP=y
# CONFIG_DEBUG_BLK_CGROUP is not set
CONFIG_CGROUP_WRITEBACK=y
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
CONFIG_CFS_BANDWIDTH=y
CONFIG_RT_GROUP_SCHED=y
# CONFIG_CGROUP_PIDS is not set
# CONFIG_CGROUP_RDMA is not set
CONFIG_CGROUP_FREEZER=y
CONFIG_CGROUP_HUGETLB=y
CONFIG_CPUSETS=y
CONFIG_PROC_PID_CPUSET=y
CONFIG_CGROUP_DEVICE=y
# CONFIG_CGROUP_CPUACCT is not set
CONFIG_CGROUP_PERF=y
# CONFIG_CGROUP_BPF is not set
# CONFIG_CGROUP_DEBUG is not set
CONFIG_SOCK_CGROUP_DATA=y
CONFIG_CHECKPOINT_RESTORE=y
CONFIG_NAMESPACES=y
CONFIG_UTS_NS=y
CONFIG_IPC_NS=y
CONFIG_USER_NS=y
CONFIG_PID_NS=y
CONFIG_NET_NS=y
CONFIG_SCHED_AUTOGROUP=y
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
CONFIG_RD_LZMA=y
CONFIG_RD_XZ=y
CONFIG_RD_LZO=y
CONFIG_RD_LZ4=y
CONFIG_INITRAMFS_COMPRESSION=".gz"
CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE=y
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
CONFIG_HAVE_UID16=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BPF=y
CONFIG_EXPERT=y
CONFIG_UID16=y
CONFIG_MULTIUSER=y
CONFIG_SGETMASK_SYSCALL=y
CONFIG_SYSFS_SYSCALL=y
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_POSIX_TIMERS=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_KALLSYMS_ABSOLUTE_PERCPU=y
CONFIG_KALLSYMS_BASE_RELATIVE=y
CONFIG_PRINTK=y
CONFIG_PRINTK_NMI=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_BPF_SYSCALL=y
CONFIG_SHMEM=y
CONFIG_AIO=y
CONFIG_ADVISE_SYSCALLS=y
CONFIG_USERFAULTFD=y
CONFIG_PCI_QUIRKS=y
CONFIG_MEMBARRIER=y
CONFIG_EMBEDDED=y
CONFIG_HAVE_PERF_EVENTS=y
# CONFIG_PC104 is not set

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_SLUB_DEBUG=y
# CONFIG_SLUB_MEMCG_SYSFS_ON is not set
# CONFIG_COMPAT_BRK is not set
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_SLOB is not set
# CONFIG_SLAB_FREELIST_RANDOM is not set
CONFIG_SLUB_CPU_PARTIAL=y
# CONFIG_SYSTEM_DATA_VERIFICATION is not set
CONFIG_PROFILING=y
CONFIG_TRACEPOINTS=y
CONFIG_KEXEC_CORE=y
CONFIG_OPROFILE=m
CONFIG_OPROFILE_EVENT_MULTIPLEX=y
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
CONFIG_KPROBES=y
CONFIG_JUMP_LABEL=y
# CONFIG_STATIC_KEYS_SELFTEST is not set
CONFIG_OPTPROBES=y
CONFIG_KPROBES_ON_FTRACE=y
# CONFIG_UPROBES is not set
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_KRETPROBES=y
CONFIG_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_NMI=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_CONTIGUOUS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_ARCH_HAS_SET_MEMORY=y
CONFIG_ARCH_WANTS_DYNAMIC_TASK_STRUCT=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_CLK=y
CONFIG_HAVE_DMA_API_DEBUG=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_PERF_REGS=y
CONFIG_HAVE_PERF_USER_STACK_DUMP=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_ALIGNED_STRUCT_PAGE=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_ARCH_WANT_COMPAT_IPC_PARSE_VERSION=y
CONFIG_ARCH_WANT_OLD_COMPAT_IPC=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_SECCOMP_FILTER=y
CONFIG_HAVE_GCC_PLUGINS=y
# CONFIG_GCC_PLUGINS is not set
CONFIG_HAVE_CC_STACKPROTECTOR=y
# CONFIG_CC_STACKPROTECTOR is not set
CONFIG_CC_STACKPROTECTOR_NONE=y
# CONFIG_CC_STACKPROTECTOR_REGULAR is not set
# CONFIG_CC_STACKPROTECTOR_STRONG is not set
CONFIG_HAVE_ARCH_WITHIN_STACK_FRAMES=y
CONFIG_HAVE_CONTEXT_TRACKING=y
CONFIG_HAVE_VIRT_CPU_ACCOUNTING_GEN=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD=y
CONFIG_HAVE_ARCH_HUGE_VMAP=y
CONFIG_HAVE_ARCH_SOFT_DIRTY=y
CONFIG_MODULES_USE_ELF_RELA=y
CONFIG_HAVE_IRQ_EXIT_ON_IRQ_STACK=y
CONFIG_ARCH_HAS_ELF_RANDOMIZE=y
CONFIG_HAVE_ARCH_MMAP_RND_BITS=y
CONFIG_HAVE_EXIT_THREAD=y
CONFIG_ARCH_MMAP_RND_BITS=28
CONFIG_HAVE_ARCH_MMAP_RND_COMPAT_BITS=y
CONFIG_ARCH_MMAP_RND_COMPAT_BITS=8
CONFIG_HAVE_COPY_THREAD_TLS=y
CONFIG_HAVE_STACK_VALIDATION=y
# CONFIG_HAVE_ARCH_HASH is not set
# CONFIG_ISA_BUS_API is not set
CONFIG_OLD_SIGSUSPEND3=y
CONFIG_COMPAT_OLD_SIGACTION=y
# CONFIG_CPU_NO_EFFICIENT_FFS is not set
CONFIG_HAVE_ARCH_VMAP_STACK=y
CONFIG_VMAP_STACK=y
# CONFIG_ARCH_OPTIONAL_KERNEL_RWX is not set
# CONFIG_ARCH_OPTIONAL_KERNEL_RWX_DEFAULT is not set
CONFIG_ARCH_HAS_STRICT_KERNEL_RWX=y
CONFIG_STRICT_KERNEL_RWX=y
CONFIG_ARCH_HAS_STRICT_MODULE_RWX=y
CONFIG_STRICT_MODULE_RWX=y

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=y
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
CONFIG_MODULES=y
CONFIG_MODULE_FORCE_LOAD=y
CONFIG_MODULE_UNLOAD=y
# CONFIG_MODULE_FORCE_UNLOAD is not set
# CONFIG_MODVERSIONS is not set
# CONFIG_MODULE_SRCVERSION_ALL is not set
# CONFIG_MODULE_SIG is not set
# CONFIG_MODULE_COMPRESS is not set
# CONFIG_TRIM_UNUSED_KSYMS is not set
CONFIG_MODULES_TREE_LOOKUP=y
CONFIG_BLOCK=y
CONFIG_BLK_SCSI_REQUEST=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
CONFIG_BLK_DEV_INTEGRITY=y
# CONFIG_BLK_DEV_ZONED is not set
CONFIG_BLK_DEV_THROTTLING=y
# CONFIG_BLK_CMDLINE_PARSER is not set
# CONFIG_BLK_WBT is not set
CONFIG_BLK_DEBUG_FS=y
# CONFIG_BLK_SED_OPAL is not set

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
# CONFIG_ACORN_PARTITION is not set
# CONFIG_AIX_PARTITION is not set
CONFIG_OSF_PARTITION=y
CONFIG_AMIGA_PARTITION=y
# CONFIG_ATARI_PARTITION is not set
CONFIG_MAC_PARTITION=y
CONFIG_MSDOS_PARTITION=y
CONFIG_BSD_DISKLABEL=y
CONFIG_MINIX_SUBPARTITION=y
CONFIG_SOLARIS_X86_PARTITION=y
CONFIG_UNIXWARE_DISKLABEL=y
# CONFIG_LDM_PARTITION is not set
CONFIG_SGI_PARTITION=y
# CONFIG_ULTRIX_PARTITION is not set
CONFIG_SUN_PARTITION=y
CONFIG_KARMA_PARTITION=y
CONFIG_EFI_PARTITION=y
# CONFIG_SYSV68_PARTITION is not set
# CONFIG_CMDLINE_PARTITION is not set
CONFIG_BLOCK_COMPAT=y
CONFIG_BLK_MQ_PCI=y
CONFIG_BLK_MQ_VIRTIO=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_DEADLINE=y
CONFIG_IOSCHED_CFQ=y
CONFIG_CFQ_GROUP_IOSCHED=y
CONFIG_DEFAULT_DEADLINE=y
# CONFIG_DEFAULT_CFQ is not set
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="deadline"
CONFIG_MQ_IOSCHED_DEADLINE=y
CONFIG_PREEMPT_NOTIFIERS=y
CONFIG_PADATA=y
CONFIG_ASN1=y
CONFIG_INLINE_SPIN_UNLOCK_IRQ=y
CONFIG_INLINE_READ_UNLOCK=y
CONFIG_INLINE_READ_UNLOCK_IRQ=y
CONFIG_INLINE_WRITE_UNLOCK=y
CONFIG_INLINE_WRITE_UNLOCK_IRQ=y
CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=y
CONFIG_MUTEX_SPIN_ON_OWNER=y
CONFIG_RWSEM_SPIN_ON_OWNER=y
CONFIG_LOCK_SPIN_ON_OWNER=y
CONFIG_ARCH_USE_QUEUED_SPINLOCKS=y
CONFIG_QUEUED_SPINLOCKS=y
CONFIG_ARCH_USE_QUEUED_RWLOCKS=y
CONFIG_QUEUED_RWLOCKS=y
CONFIG_FREEZER=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
CONFIG_SMP=y
CONFIG_X86_FEATURE_NAMES=y
CONFIG_X86_FAST_FEATURE_TESTS=y
CONFIG_X86_X2APIC=y
CONFIG_X86_MPPARSE=y
# CONFIG_GOLDFISH is not set
CONFIG_INTEL_RDT_A=y
CONFIG_X86_EXTENDED_PLATFORM=y
# CONFIG_X86_NUMACHIP is not set
# CONFIG_X86_VSMP is not set
CONFIG_X86_UV=y
# CONFIG_X86_GOLDFISH is not set
# CONFIG_X86_INTEL_MID is not set
CONFIG_X86_INTEL_LPSS=y
# CONFIG_X86_AMD_PLATFORM_DEVICE is not set
CONFIG_IOSF_MBI=y
# CONFIG_IOSF_MBI_DEBUG is not set
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
CONFIG_PARAVIRT_SPINLOCKS=y
# CONFIG_QUEUED_LOCK_STAT is not set
CONFIG_XEN=y
CONFIG_XEN_DOM0=y
CONFIG_XEN_PVHVM=y
CONFIG_XEN_512GB=y
CONFIG_XEN_SAVE_RESTORE=y
# CONFIG_XEN_DEBUG_FS is not set
# CONFIG_XEN_PVH is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
CONFIG_PARAVIRT_TIME_ACCOUNTING=y
CONFIG_PARAVIRT_CLOCK=y
CONFIG_NO_BOOTMEM=y
# CONFIG_MK8 is not set
# CONFIG_MPSC is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
CONFIG_GENERIC_CPU=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
# CONFIG_PROCESSOR_SELECT is not set
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
CONFIG_DMI=y
CONFIG_GART_IOMMU=y
# CONFIG_CALGARY_IOMMU is not set
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_MAXSMP=y
CONFIG_NR_CPUS=8192
CONFIG_SCHED_SMT=y
CONFIG_SCHED_MC=y
CONFIG_SCHED_MC_PRIO=y
# CONFIG_PREEMPT_NONE is not set
CONFIG_PREEMPT_VOLUNTARY=y
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=y
CONFIG_X86_MCE=y
CONFIG_X86_MCE_INTEL=y
CONFIG_X86_MCE_AMD=y
CONFIG_X86_MCE_THRESHOLD=y
CONFIG_X86_MCE_INJECT=m
CONFIG_X86_THERMAL_VECTOR=y

#
# Performance monitoring
#
CONFIG_PERF_EVENTS_INTEL_UNCORE=y
CONFIG_PERF_EVENTS_INTEL_RAPL=y
CONFIG_PERF_EVENTS_INTEL_CSTATE=y
# CONFIG_PERF_EVENTS_AMD_POWER is not set
# CONFIG_VM86 is not set
CONFIG_X86_16BIT=y
CONFIG_X86_ESPFIX64=y
CONFIG_X86_VSYSCALL_EMULATION=y
CONFIG_I8K=m
CONFIG_MICROCODE=y
CONFIG_MICROCODE_INTEL=y
CONFIG_MICROCODE_AMD=y
CONFIG_MICROCODE_OLD_INTERFACE=y
CONFIG_X86_MSR=y
CONFIG_X86_CPUID=y
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_X86_DIRECT_GBPAGES=y
CONFIG_NUMA=y
CONFIG_AMD_NUMA=y
CONFIG_X86_64_ACPI_NUMA=y
CONFIG_NODES_SPAN_OTHER_NODES=y
# CONFIG_NUMA_EMU is not set
CONFIG_NODES_SHIFT=10
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ARCH_MEMORY_PROBE=y
CONFIG_ARCH_PROC_KCORE_TEXT=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_NEED_MULTIPLE_NODES=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
CONFIG_SPARSEMEM_VMEMMAP=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
CONFIG_MOVABLE_NODE=y
CONFIG_HAVE_BOOTMEM_INFO_NODE=y
CONFIG_MEMORY_HOTPLUG=y
CONFIG_MEMORY_HOTPLUG_SPARSE=y
# CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE is not set
CONFIG_MEMORY_HOTREMOVE=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y
CONFIG_MEMORY_BALLOON=y
CONFIG_BALLOON_COMPACTION=y
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_BOUNCE=y
CONFIG_VIRT_TO_BUS=y
CONFIG_MMU_NOTIFIER=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
CONFIG_MEMORY_FAILURE=y
CONFIG_HWPOISON_INJECT=m
CONFIG_TRANSPARENT_HUGEPAGE=y
CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=y
# CONFIG_TRANSPARENT_HUGEPAGE_MADVISE is not set
CONFIG_TRANSPARENT_HUGE_PAGECACHE=y
CONFIG_CLEANCACHE=y
CONFIG_FRONTSWAP=y
CONFIG_CMA=y
# CONFIG_CMA_DEBUG is not set
# CONFIG_CMA_DEBUGFS is not set
CONFIG_CMA_AREAS=7
# CONFIG_MEM_SOFT_DIRTY is not set
CONFIG_ZSWAP=y
CONFIG_ZPOOL=y
CONFIG_ZBUD=y
# CONFIG_Z3FOLD is not set
CONFIG_ZSMALLOC=y
# CONFIG_PGTABLE_MAPPING is not set
# CONFIG_ZSMALLOC_STAT is not set
CONFIG_GENERIC_EARLY_IOREMAP=y
CONFIG_ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT=y
# CONFIG_DEFERRED_STRUCT_PAGE_INIT is not set
# CONFIG_IDLE_PAGE_TRACKING is not set
CONFIG_ZONE_DEVICE=y
CONFIG_FRAME_VECTOR=y
CONFIG_ARCH_USES_HIGH_VMA_FLAGS=y
CONFIG_ARCH_HAS_PKEYS=y
CONFIG_X86_PMEM_LEGACY_DEVICE=y
CONFIG_X86_PMEM_LEGACY=m
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
# CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK is not set
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
CONFIG_MTRR_SANITIZER=y
CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=0
CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT=1
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
CONFIG_ARCH_RANDOM=y
CONFIG_X86_SMAP=y
# CONFIG_X86_INTEL_MPX is not set
CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS=y
CONFIG_EFI=y
CONFIG_EFI_STUB=y
# CONFIG_EFI_MIXED is not set
CONFIG_SECCOMP=y
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
CONFIG_HZ_1000=y
CONFIG_HZ=1000
CONFIG_SCHED_HRTICK=y
CONFIG_KEXEC=y
# CONFIG_KEXEC_FILE is not set
CONFIG_CRASH_DUMP=y
CONFIG_KEXEC_JUMP=y
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
# CONFIG_RANDOMIZE_BASE is not set
CONFIG_PHYSICAL_ALIGN=0x1000000
CONFIG_HOTPLUG_CPU=y
# CONFIG_BOOTPARAM_HOTPLUG_CPU0 is not set
# CONFIG_DEBUG_HOTPLUG_CPU0 is not set
# CONFIG_COMPAT_VDSO is not set
# CONFIG_LEGACY_VSYSCALL_NATIVE is not set
CONFIG_LEGACY_VSYSCALL_EMULATE=y
# CONFIG_LEGACY_VSYSCALL_NONE is not set
# CONFIG_CMDLINE_BOOL is not set
CONFIG_MODIFY_LDT_SYSCALL=y
CONFIG_HAVE_LIVEPATCH=y
# CONFIG_LIVEPATCH is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y
CONFIG_USE_PERCPU_NUMA_NODE_ID=y

#
# Power management and ACPI options
#
CONFIG_ARCH_HIBERNATION_HEADER=y
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
# CONFIG_SUSPEND_SKIP_SYNC is not set
CONFIG_HIBERNATE_CALLBACKS=y
CONFIG_HIBERNATION=y
CONFIG_PM_STD_PARTITION=""
CONFIG_PM_SLEEP=y
CONFIG_PM_SLEEP_SMP=y
# CONFIG_PM_AUTOSLEEP is not set
# CONFIG_PM_WAKELOCKS is not set
CONFIG_PM=y
CONFIG_PM_DEBUG=y
CONFIG_PM_ADVANCED_DEBUG=y
CONFIG_PM_TEST_SUSPEND=y
CONFIG_PM_SLEEP_DEBUG=y
# CONFIG_DPM_WATCHDOG is not set
# CONFIG_PM_TRACE_RTC is not set
CONFIG_PM_CLK=y
# CONFIG_WQ_POWER_EFFICIENT_DEFAULT is not set
CONFIG_ACPI=y
CONFIG_ACPI_LEGACY_TABLES_LOOKUP=y
CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=y
CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT=y
# CONFIG_ACPI_DEBUGGER is not set
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_PROCFS_POWER is not set
CONFIG_ACPI_REV_OVERRIDE_POSSIBLE=y
CONFIG_ACPI_EC_DEBUGFS=m
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_VIDEO=m
CONFIG_ACPI_FAN=y
CONFIG_ACPI_DOCK=y
CONFIG_ACPI_CPU_FREQ_PSS=y
CONFIG_ACPI_PROCESSOR_CSTATE=y
CONFIG_ACPI_PROCESSOR_IDLE=y
CONFIG_ACPI_CPPC_LIB=y
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_IPMI=m
CONFIG_ACPI_HOTPLUG_CPU=y
CONFIG_ACPI_PROCESSOR_AGGREGATOR=m
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_NUMA=y
# CONFIG_ACPI_CUSTOM_DSDT is not set
CONFIG_ARCH_HAS_ACPI_TABLE_UPGRADE=y
CONFIG_ACPI_TABLE_UPGRADE=y
CONFIG_ACPI_DEBUG=y
CONFIG_ACPI_PCI_SLOT=y
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_CONTAINER=y
CONFIG_ACPI_HOTPLUG_MEMORY=y
CONFIG_ACPI_HOTPLUG_IOAPIC=y
CONFIG_ACPI_SBS=m
CONFIG_ACPI_HED=y
CONFIG_ACPI_CUSTOM_METHOD=m
CONFIG_ACPI_BGRT=y
# CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
CONFIG_ACPI_NFIT=m
# CONFIG_ACPI_NFIT_DEBUG is not set
CONFIG_HAVE_ACPI_APEI=y
CONFIG_HAVE_ACPI_APEI_NMI=y
CONFIG_ACPI_APEI=y
CONFIG_ACPI_APEI_GHES=y
CONFIG_ACPI_APEI_PCIEAER=y
CONFIG_ACPI_APEI_MEMORY_FAILURE=y
CONFIG_ACPI_APEI_EINJ=m
# CONFIG_ACPI_APEI_ERST_DEBUG is not set
# CONFIG_DPTF_POWER is not set
# CONFIG_ACPI_EXTLOG is not set
# CONFIG_PMIC_OPREGION is not set
# CONFIG_ACPI_CONFIGFS is not set
CONFIG_SFI=y

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_GOV_ATTR_SET=y
CONFIG_CPU_FREQ_GOV_COMMON=y
# CONFIG_CPU_FREQ_STAT is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_SCHEDUTIL is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_POWERSAVE=y
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y
# CONFIG_CPU_FREQ_GOV_SCHEDUTIL is not set

#
# CPU frequency scaling drivers
#
CONFIG_X86_INTEL_PSTATE=y
CONFIG_X86_PCC_CPUFREQ=m
CONFIG_X86_ACPI_CPUFREQ=m
CONFIG_X86_ACPI_CPUFREQ_CPB=y
CONFIG_X86_POWERNOW_K8=m
CONFIG_X86_AMD_FREQ_SENSITIVITY=m
# CONFIG_X86_SPEEDSTEP_CENTRINO is not set
CONFIG_X86_P4_CLOCKMOD=m

#
# shared options
#
CONFIG_X86_SPEEDSTEP_LIB=m

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
# CONFIG_CPU_IDLE_GOV_LADDER is not set
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
CONFIG_INTEL_IDLE=y

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_XEN=y
CONFIG_PCI_DOMAINS=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
CONFIG_PCIEPORTBUS=y
CONFIG_HOTPLUG_PCI_PCIE=y
CONFIG_PCIEAER=y
CONFIG_PCIE_ECRC=y
CONFIG_PCIEAER_INJECT=m
CONFIG_PCIEASPM=y
# CONFIG_PCIEASPM_DEBUG is not set
CONFIG_PCIEASPM_DEFAULT=y
# CONFIG_PCIEASPM_POWERSAVE is not set
# CONFIG_PCIEASPM_POWER_SUPERSAVE is not set
# CONFIG_PCIEASPM_PERFORMANCE is not set
CONFIG_PCIE_PME=y
# CONFIG_PCIE_DPC is not set
# CONFIG_PCIE_PTM is not set
CONFIG_PCI_BUS_ADDR_T_64BIT=y
CONFIG_PCI_MSI=y
CONFIG_PCI_MSI_IRQ_DOMAIN=y
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
CONFIG_PCI_STUB=y
# CONFIG_XEN_PCIDEV_FRONTEND is not set
CONFIG_HT_IRQ=y
CONFIG_PCI_ATS=y
CONFIG_PCI_IOV=y
CONFIG_PCI_PRI=y
CONFIG_PCI_PASID=y
CONFIG_PCI_LABEL=y
# CONFIG_PCI_HYPERV is not set
CONFIG_HOTPLUG_PCI=y
CONFIG_HOTPLUG_PCI_ACPI=y
CONFIG_HOTPLUG_PCI_ACPI_IBM=m
# CONFIG_HOTPLUG_PCI_CPCI is not set
CONFIG_HOTPLUG_PCI_SHPC=m

#
# DesignWare PCI Core Support
#
# CONFIG_PCIE_DW_PLAT is not set

#
# PCI host controller drivers
#
# CONFIG_VMD is not set
# CONFIG_ISA_BUS is not set
CONFIG_ISA_DMA_API=y
CONFIG_AMD_NB=y
CONFIG_PCCARD=y
# CONFIG_PCMCIA is not set
CONFIG_CARDBUS=y

#
# PC-card bridges
#
CONFIG_YENTA=m
CONFIG_YENTA_O2=y
CONFIG_YENTA_RICOH=y
CONFIG_YENTA_TI=y
CONFIG_YENTA_ENE_TUNE=y
CONFIG_YENTA_TOSHIBA=y
# CONFIG_RAPIDIO is not set
# CONFIG_X86_SYSFB is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_COMPAT_BINFMT_ELF=y
CONFIG_ELFCORE=y
CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS=y
CONFIG_BINFMT_SCRIPT=y
# CONFIG_HAVE_AOUT is not set
CONFIG_BINFMT_MISC=m
CONFIG_COREDUMP=y
CONFIG_IA32_EMULATION=y
# CONFIG_IA32_AOUT is not set
# CONFIG_X86_X32 is not set
CONFIG_COMPAT_32=y
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_SYSVIPC_COMPAT=y
CONFIG_KEYS_COMPAT=y
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_NET=y
CONFIG_COMPAT_NETLINK_MESSAGES=y
CONFIG_NET_INGRESS=y
CONFIG_NET_EGRESS=y

#
# Networking options
#
CONFIG_PACKET=y
CONFIG_PACKET_DIAG=m
CONFIG_UNIX=y
CONFIG_UNIX_DIAG=m
CONFIG_XFRM=y
CONFIG_XFRM_ALGO=y
CONFIG_XFRM_USER=y
CONFIG_XFRM_SUB_POLICY=y
CONFIG_XFRM_MIGRATE=y
CONFIG_XFRM_STATISTICS=y
CONFIG_XFRM_IPCOMP=m
CONFIG_NET_KEY=m
CONFIG_NET_KEY_MIGRATE=y
CONFIG_INET=y
CONFIG_IP_MULTICAST=y
CONFIG_IP_ADVANCED_ROUTER=y
CONFIG_IP_FIB_TRIE_STATS=y
CONFIG_IP_MULTIPLE_TABLES=y
CONFIG_IP_ROUTE_MULTIPATH=y
CONFIG_IP_ROUTE_VERBOSE=y
CONFIG_IP_ROUTE_CLASSID=y
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
# CONFIG_IP_PNP_BOOTP is not set
# CONFIG_IP_PNP_RARP is not set
CONFIG_NET_IPIP=m
CONFIG_NET_IPGRE_DEMUX=m
CONFIG_NET_IP_TUNNEL=m
CONFIG_NET_IPGRE=m
CONFIG_NET_IPGRE_BROADCAST=y
CONFIG_IP_MROUTE=y
CONFIG_IP_MROUTE_MULTIPLE_TABLES=y
CONFIG_IP_PIMSM_V1=y
CONFIG_IP_PIMSM_V2=y
CONFIG_SYN_COOKIES=y
CONFIG_NET_IPVTI=m
CONFIG_NET_UDP_TUNNEL=m
# CONFIG_NET_FOU is not set
# CONFIG_NET_FOU_IP_TUNNELS is not set
CONFIG_INET_AH=m
CONFIG_INET_ESP=m
# CONFIG_INET_ESP_OFFLOAD is not set
CONFIG_INET_IPCOMP=m
CONFIG_INET_XFRM_TUNNEL=m
CONFIG_INET_TUNNEL=m
CONFIG_INET_XFRM_MODE_TRANSPORT=m
CONFIG_INET_XFRM_MODE_TUNNEL=m
CONFIG_INET_XFRM_MODE_BEET=m
CONFIG_INET_DIAG=m
CONFIG_INET_TCP_DIAG=m
CONFIG_INET_UDP_DIAG=m
# CONFIG_INET_RAW_DIAG is not set
# CONFIG_INET_DIAG_DESTROY is not set
CONFIG_TCP_CONG_ADVANCED=y
CONFIG_TCP_CONG_BIC=m
CONFIG_TCP_CONG_CUBIC=y
CONFIG_TCP_CONG_WESTWOOD=m
CONFIG_TCP_CONG_HTCP=m
CONFIG_TCP_CONG_HSTCP=m
CONFIG_TCP_CONG_HYBLA=m
CONFIG_TCP_CONG_VEGAS=m
# CONFIG_TCP_CONG_NV is not set
CONFIG_TCP_CONG_SCALABLE=m
CONFIG_TCP_CONG_LP=m
CONFIG_TCP_CONG_VENO=m
CONFIG_TCP_CONG_YEAH=m
CONFIG_TCP_CONG_ILLINOIS=m
# CONFIG_TCP_CONG_DCTCP is not set
# CONFIG_TCP_CONG_CDG is not set
# CONFIG_TCP_CONG_BBR is not set
CONFIG_DEFAULT_CUBIC=y
# CONFIG_DEFAULT_RENO is not set
CONFIG_DEFAULT_TCP_CONG="cubic"
CONFIG_TCP_MD5SIG=y
CONFIG_IPV6=y
CONFIG_IPV6_ROUTER_PREF=y
CONFIG_IPV6_ROUTE_INFO=y
CONFIG_IPV6_OPTIMISTIC_DAD=y
CONFIG_INET6_AH=m
CONFIG_INET6_ESP=m
# CONFIG_INET6_ESP_OFFLOAD is not set
CONFIG_INET6_IPCOMP=m
CONFIG_IPV6_MIP6=m
# CONFIG_IPV6_ILA is not set
CONFIG_INET6_XFRM_TUNNEL=m
CONFIG_INET6_TUNNEL=m
CONFIG_INET6_XFRM_MODE_TRANSPORT=m
CONFIG_INET6_XFRM_MODE_TUNNEL=m
CONFIG_INET6_XFRM_MODE_BEET=m
CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION=m
# CONFIG_IPV6_VTI is not set
CONFIG_IPV6_SIT=m
CONFIG_IPV6_SIT_6RD=y
CONFIG_IPV6_NDISC_NODETYPE=y
CONFIG_IPV6_TUNNEL=m
# CONFIG_IPV6_GRE is not set
# CONFIG_IPV6_FOU is not set
# CONFIG_IPV6_FOU_TUNNEL is not set
CONFIG_IPV6_MULTIPLE_TABLES=y
# CONFIG_IPV6_SUBTREES is not set
CONFIG_IPV6_MROUTE=y
CONFIG_IPV6_MROUTE_MULTIPLE_TABLES=y
CONFIG_IPV6_PIMSM_V2=y
# CONFIG_IPV6_SEG6_LWTUNNEL is not set
# CONFIG_IPV6_SEG6_HMAC is not set
CONFIG_NETLABEL=y
CONFIG_NETWORK_SECMARK=y
CONFIG_NET_PTP_CLASSIFY=y
CONFIG_NETWORK_PHY_TIMESTAMPING=y
CONFIG_NETFILTER=y
# CONFIG_NETFILTER_DEBUG is not set
CONFIG_NETFILTER_ADVANCED=y
CONFIG_BRIDGE_NETFILTER=m

#
# Core Netfilter Configuration
#
CONFIG_NETFILTER_INGRESS=y
CONFIG_NETFILTER_NETLINK=m
CONFIG_NETFILTER_NETLINK_ACCT=m
CONFIG_NETFILTER_NETLINK_QUEUE=m
CONFIG_NETFILTER_NETLINK_LOG=m
CONFIG_NF_CONNTRACK=m
CONFIG_NF_LOG_COMMON=m
# CONFIG_NF_LOG_NETDEV is not set
CONFIG_NF_CONNTRACK_MARK=y
CONFIG_NF_CONNTRACK_SECMARK=y
CONFIG_NF_CONNTRACK_ZONES=y
CONFIG_NF_CONNTRACK_PROCFS=y
CONFIG_NF_CONNTRACK_EVENTS=y
# CONFIG_NF_CONNTRACK_TIMEOUT is not set
CONFIG_NF_CONNTRACK_TIMESTAMP=y
CONFIG_NF_CONNTRACK_LABELS=y
CONFIG_NF_CT_PROTO_DCCP=y
CONFIG_NF_CT_PROTO_GRE=m
CONFIG_NF_CT_PROTO_SCTP=y
CONFIG_NF_CT_PROTO_UDPLITE=y
CONFIG_NF_CONNTRACK_AMANDA=m
CONFIG_NF_CONNTRACK_FTP=m
CONFIG_NF_CONNTRACK_H323=m
CONFIG_NF_CONNTRACK_IRC=m
CONFIG_NF_CONNTRACK_BROADCAST=m
CONFIG_NF_CONNTRACK_NETBIOS_NS=m
CONFIG_NF_CONNTRACK_SNMP=m
CONFIG_NF_CONNTRACK_PPTP=m
CONFIG_NF_CONNTRACK_SANE=m
CONFIG_NF_CONNTRACK_SIP=m
CONFIG_NF_CONNTRACK_TFTP=m
CONFIG_NF_CT_NETLINK=m
# CONFIG_NF_CT_NETLINK_TIMEOUT is not set
# CONFIG_NETFILTER_NETLINK_GLUE_CT is not set
CONFIG_NF_NAT=m
CONFIG_NF_NAT_NEEDED=y
CONFIG_NF_NAT_PROTO_DCCP=y
CONFIG_NF_NAT_PROTO_UDPLITE=y
CONFIG_NF_NAT_PROTO_SCTP=y
CONFIG_NF_NAT_AMANDA=m
CONFIG_NF_NAT_FTP=m
CONFIG_NF_NAT_IRC=m
CONFIG_NF_NAT_SIP=m
CONFIG_NF_NAT_TFTP=m
CONFIG_NF_NAT_REDIRECT=m
CONFIG_NETFILTER_SYNPROXY=m
CONFIG_NF_TABLES=m
# CONFIG_NF_TABLES_INET is not set
# CONFIG_NF_TABLES_NETDEV is not set
CONFIG_NFT_EXTHDR=m
CONFIG_NFT_META=m
# CONFIG_NFT_RT is not set
# CONFIG_NFT_NUMGEN is not set
CONFIG_NFT_CT=m
# CONFIG_NFT_SET_RBTREE is not set
# CONFIG_NFT_SET_HASH is not set
# CONFIG_NFT_SET_BITMAP is not set
CONFIG_NFT_COUNTER=m
CONFIG_NFT_LOG=m
CONFIG_NFT_LIMIT=m
# CONFIG_NFT_MASQ is not set
# CONFIG_NFT_REDIR is not set
CONFIG_NFT_NAT=m
# CONFIG_NFT_OBJREF is not set
# CONFIG_NFT_QUEUE is not set
# CONFIG_NFT_QUOTA is not set
# CONFIG_NFT_REJECT is not set
CONFIG_NFT_COMPAT=m
CONFIG_NFT_HASH=m
CONFIG_NETFILTER_XTABLES=y

#
# Xtables combined modules
#
CONFIG_NETFILTER_XT_MARK=m
CONFIG_NETFILTER_XT_CONNMARK=m
CONFIG_NETFILTER_XT_SET=m

#
# Xtables targets
#
CONFIG_NETFILTER_XT_TARGET_AUDIT=m
CONFIG_NETFILTER_XT_TARGET_CHECKSUM=m
CONFIG_NETFILTER_XT_TARGET_CLASSIFY=m
CONFIG_NETFILTER_XT_TARGET_CONNMARK=m
CONFIG_NETFILTER_XT_TARGET_CONNSECMARK=m
CONFIG_NETFILTER_XT_TARGET_CT=m
CONFIG_NETFILTER_XT_TARGET_DSCP=m
CONFIG_NETFILTER_XT_TARGET_HL=m
CONFIG_NETFILTER_XT_TARGET_HMARK=m
CONFIG_NETFILTER_XT_TARGET_IDLETIMER=m
CONFIG_NETFILTER_XT_TARGET_LED=m
CONFIG_NETFILTER_XT_TARGET_LOG=m
CONFIG_NETFILTER_XT_TARGET_MARK=m
CONFIG_NETFILTER_XT_NAT=m
CONFIG_NETFILTER_XT_TARGET_NETMAP=m
CONFIG_NETFILTER_XT_TARGET_NFLOG=m
CONFIG_NETFILTER_XT_TARGET_NFQUEUE=m
CONFIG_NETFILTER_XT_TARGET_NOTRACK=m
CONFIG_NETFILTER_XT_TARGET_RATEEST=m
CONFIG_NETFILTER_XT_TARGET_REDIRECT=m
CONFIG_NETFILTER_XT_TARGET_TEE=m
CONFIG_NETFILTER_XT_TARGET_TPROXY=m
CONFIG_NETFILTER_XT_TARGET_TRACE=m
CONFIG_NETFILTER_XT_TARGET_SECMARK=m
CONFIG_NETFILTER_XT_TARGET_TCPMSS=m
CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP=m

#
# Xtables matches
#
CONFIG_NETFILTER_XT_MATCH_ADDRTYPE=m
CONFIG_NETFILTER_XT_MATCH_BPF=m
# CONFIG_NETFILTER_XT_MATCH_CGROUP is not set
CONFIG_NETFILTER_XT_MATCH_CLUSTER=m
CONFIG_NETFILTER_XT_MATCH_COMMENT=m
CONFIG_NETFILTER_XT_MATCH_CONNBYTES=m
CONFIG_NETFILTER_XT_MATCH_CONNLABEL=m
CONFIG_NETFILTER_XT_MATCH_CONNLIMIT=m
CONFIG_NETFILTER_XT_MATCH_CONNMARK=m
CONFIG_NETFILTER_XT_MATCH_CONNTRACK=m
CONFIG_NETFILTER_XT_MATCH_CPU=m
CONFIG_NETFILTER_XT_MATCH_DCCP=m
CONFIG_NETFILTER_XT_MATCH_DEVGROUP=m
CONFIG_NETFILTER_XT_MATCH_DSCP=m
CONFIG_NETFILTER_XT_MATCH_ECN=m
CONFIG_NETFILTER_XT_MATCH_ESP=m
CONFIG_NETFILTER_XT_MATCH_HASHLIMIT=m
CONFIG_NETFILTER_XT_MATCH_HELPER=m
CONFIG_NETFILTER_XT_MATCH_HL=m
# CONFIG_NETFILTER_XT_MATCH_IPCOMP is not set
CONFIG_NETFILTER_XT_MATCH_IPRANGE=m
CONFIG_NETFILTER_XT_MATCH_IPVS=m
CONFIG_NETFILTER_XT_MATCH_L2TP=m
CONFIG_NETFILTER_XT_MATCH_LENGTH=m
CONFIG_NETFILTER_XT_MATCH_LIMIT=m
CONFIG_NETFILTER_XT_MATCH_MAC=m
CONFIG_NETFILTER_XT_MATCH_MARK=m
CONFIG_NETFILTER_XT_MATCH_MULTIPORT=m
CONFIG_NETFILTER_XT_MATCH_NFACCT=m
CONFIG_NETFILTER_XT_MATCH_OSF=m
CONFIG_NETFILTER_XT_MATCH_OWNER=m
CONFIG_NETFILTER_XT_MATCH_POLICY=m
CONFIG_NETFILTER_XT_MATCH_PHYSDEV=m
CONFIG_NETFILTER_XT_MATCH_PKTTYPE=m
CONFIG_NETFILTER_XT_MATCH_QUOTA=m
CONFIG_NETFILTER_XT_MATCH_RATEEST=m
CONFIG_NETFILTER_XT_MATCH_REALM=m
CONFIG_NETFILTER_XT_MATCH_RECENT=m
CONFIG_NETFILTER_XT_MATCH_SCTP=m
CONFIG_NETFILTER_XT_MATCH_STATE=m
CONFIG_NETFILTER_XT_MATCH_STATISTIC=m
CONFIG_NETFILTER_XT_MATCH_STRING=m
CONFIG_NETFILTER_XT_MATCH_TCPMSS=m
CONFIG_NETFILTER_XT_MATCH_TIME=m
CONFIG_NETFILTER_XT_MATCH_U32=m
CONFIG_IP_SET=m
CONFIG_IP_SET_MAX=256
CONFIG_IP_SET_BITMAP_IP=m
CONFIG_IP_SET_BITMAP_IPMAC=m
CONFIG_IP_SET_BITMAP_PORT=m
CONFIG_IP_SET_HASH_IP=m
# CONFIG_IP_SET_HASH_IPMARK is not set
CONFIG_IP_SET_HASH_IPPORT=m
CONFIG_IP_SET_HASH_IPPORTIP=m
CONFIG_IP_SET_HASH_IPPORTNET=m
# CONFIG_IP_SET_HASH_IPMAC is not set
# CONFIG_IP_SET_HASH_MAC is not set
# CONFIG_IP_SET_HASH_NETPORTNET is not set
CONFIG_IP_SET_HASH_NET=m
# CONFIG_IP_SET_HASH_NETNET is not set
CONFIG_IP_SET_HASH_NETPORT=m
CONFIG_IP_SET_HASH_NETIFACE=m
CONFIG_IP_SET_LIST_SET=m
CONFIG_IP_VS=m
CONFIG_IP_VS_IPV6=y
# CONFIG_IP_VS_DEBUG is not set
CONFIG_IP_VS_TAB_BITS=12

#
# IPVS transport protocol load balancing support
#
CONFIG_IP_VS_PROTO_TCP=y
CONFIG_IP_VS_PROTO_UDP=y
CONFIG_IP_VS_PROTO_AH_ESP=y
CONFIG_IP_VS_PROTO_ESP=y
CONFIG_IP_VS_PROTO_AH=y
CONFIG_IP_VS_PROTO_SCTP=y

#
# IPVS scheduler
#
CONFIG_IP_VS_RR=m
CONFIG_IP_VS_WRR=m
CONFIG_IP_VS_LC=m
CONFIG_IP_VS_WLC=m
# CONFIG_IP_VS_FO is not set
# CONFIG_IP_VS_OVF is not set
CONFIG_IP_VS_LBLC=m
CONFIG_IP_VS_LBLCR=m
CONFIG_IP_VS_DH=m
CONFIG_IP_VS_SH=m
CONFIG_IP_VS_SED=m
CONFIG_IP_VS_NQ=m

#
# IPVS SH scheduler
#
CONFIG_IP_VS_SH_TAB_BITS=8

#
# IPVS application helper
#
CONFIG_IP_VS_FTP=m
CONFIG_IP_VS_NFCT=y
CONFIG_IP_VS_PE_SIP=m

#
# IP: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV4=m
CONFIG_NF_CONNTRACK_IPV4=m
# CONFIG_NF_SOCKET_IPV4 is not set
CONFIG_NF_TABLES_IPV4=m
CONFIG_NFT_CHAIN_ROUTE_IPV4=m
# CONFIG_NFT_REJECT_IPV4 is not set
# CONFIG_NFT_DUP_IPV4 is not set
# CONFIG_NFT_FIB_IPV4 is not set
# CONFIG_NF_TABLES_ARP is not set
CONFIG_NF_DUP_IPV4=m
# CONFIG_NF_LOG_ARP is not set
CONFIG_NF_LOG_IPV4=m
CONFIG_NF_REJECT_IPV4=m
CONFIG_NF_NAT_IPV4=m
CONFIG_NFT_CHAIN_NAT_IPV4=m
CONFIG_NF_NAT_MASQUERADE_IPV4=m
CONFIG_NF_NAT_SNMP_BASIC=m
CONFIG_NF_NAT_PROTO_GRE=m
CONFIG_NF_NAT_PPTP=m
CONFIG_NF_NAT_H323=m
CONFIG_IP_NF_IPTABLES=m
CONFIG_IP_NF_MATCH_AH=m
CONFIG_IP_NF_MATCH_ECN=m
CONFIG_IP_NF_MATCH_RPFILTER=m
CONFIG_IP_NF_MATCH_TTL=m
CONFIG_IP_NF_FILTER=m
CONFIG_IP_NF_TARGET_REJECT=m
CONFIG_IP_NF_TARGET_SYNPROXY=m
CONFIG_IP_NF_NAT=m
CONFIG_IP_NF_TARGET_MASQUERADE=m
CONFIG_IP_NF_TARGET_NETMAP=m
CONFIG_IP_NF_TARGET_REDIRECT=m
CONFIG_IP_NF_MANGLE=m
CONFIG_IP_NF_TARGET_CLUSTERIP=m
CONFIG_IP_NF_TARGET_ECN=m
CONFIG_IP_NF_TARGET_TTL=m
CONFIG_IP_NF_RAW=m
CONFIG_IP_NF_SECURITY=m
CONFIG_IP_NF_ARPTABLES=m
CONFIG_IP_NF_ARPFILTER=m
CONFIG_IP_NF_ARP_MANGLE=m

#
# IPv6: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV6=m
CONFIG_NF_CONNTRACK_IPV6=m
# CONFIG_NF_SOCKET_IPV6 is not set
CONFIG_NF_TABLES_IPV6=m
CONFIG_NFT_CHAIN_ROUTE_IPV6=m
# CONFIG_NFT_REJECT_IPV6 is not set
# CONFIG_NFT_DUP_IPV6 is not set
# CONFIG_NFT_FIB_IPV6 is not set
CONFIG_NF_DUP_IPV6=m
CONFIG_NF_REJECT_IPV6=m
CONFIG_NF_LOG_IPV6=m
CONFIG_NF_NAT_IPV6=m
CONFIG_NFT_CHAIN_NAT_IPV6=m
# CONFIG_NF_NAT_MASQUERADE_IPV6 is not set
CONFIG_IP6_NF_IPTABLES=m
CONFIG_IP6_NF_MATCH_AH=m
CONFIG_IP6_NF_MATCH_EUI64=m
CONFIG_IP6_NF_MATCH_FRAG=m
CONFIG_IP6_NF_MATCH_OPTS=m
CONFIG_IP6_NF_MATCH_HL=m
CONFIG_IP6_NF_MATCH_IPV6HEADER=m
CONFIG_IP6_NF_MATCH_MH=m
CONFIG_IP6_NF_MATCH_RPFILTER=m
CONFIG_IP6_NF_MATCH_RT=m
CONFIG_IP6_NF_TARGET_HL=m
CONFIG_IP6_NF_FILTER=m
CONFIG_IP6_NF_TARGET_REJECT=m
CONFIG_IP6_NF_TARGET_SYNPROXY=m
CONFIG_IP6_NF_MANGLE=m
CONFIG_IP6_NF_RAW=m
CONFIG_IP6_NF_SECURITY=m
# CONFIG_IP6_NF_NAT is not set
CONFIG_NF_TABLES_BRIDGE=m
# CONFIG_NFT_BRIDGE_META is not set
# CONFIG_NF_LOG_BRIDGE is not set
CONFIG_BRIDGE_NF_EBTABLES=m
CONFIG_BRIDGE_EBT_BROUTE=m
CONFIG_BRIDGE_EBT_T_FILTER=m
CONFIG_BRIDGE_EBT_T_NAT=m
CONFIG_BRIDGE_EBT_802_3=m
CONFIG_BRIDGE_EBT_AMONG=m
CONFIG_BRIDGE_EBT_ARP=m
CONFIG_BRIDGE_EBT_IP=m
CONFIG_BRIDGE_EBT_IP6=m
CONFIG_BRIDGE_EBT_LIMIT=m
CONFIG_BRIDGE_EBT_MARK=m
CONFIG_BRIDGE_EBT_PKTTYPE=m
CONFIG_BRIDGE_EBT_STP=m
CONFIG_BRIDGE_EBT_VLAN=m
CONFIG_BRIDGE_EBT_ARPREPLY=m
CONFIG_BRIDGE_EBT_DNAT=m
CONFIG_BRIDGE_EBT_MARK_T=m
CONFIG_BRIDGE_EBT_REDIRECT=m
CONFIG_BRIDGE_EBT_SNAT=m
CONFIG_BRIDGE_EBT_LOG=m
CONFIG_BRIDGE_EBT_NFLOG=m
CONFIG_IP_DCCP=m
CONFIG_INET_DCCP_DIAG=m

#
# DCCP CCIDs Configuration
#
# CONFIG_IP_DCCP_CCID2_DEBUG is not set
CONFIG_IP_DCCP_CCID3=y
# CONFIG_IP_DCCP_CCID3_DEBUG is not set
CONFIG_IP_DCCP_TFRC_LIB=y

#
# DCCP Kernel Hacking
#
# CONFIG_IP_DCCP_DEBUG is not set
# CONFIG_NET_DCCPPROBE is not set
CONFIG_IP_SCTP=m
CONFIG_NET_SCTPPROBE=m
# CONFIG_SCTP_DBG_OBJCNT is not set
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_MD5 is not set
CONFIG_SCTP_DEFAULT_COOKIE_HMAC_SHA1=y
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_NONE is not set
CONFIG_SCTP_COOKIE_HMAC_MD5=y
CONFIG_SCTP_COOKIE_HMAC_SHA1=y
CONFIG_INET_SCTP_DIAG=m
# CONFIG_RDS is not set
CONFIG_TIPC=m
CONFIG_TIPC_MEDIA_UDP=y
CONFIG_ATM=m
CONFIG_ATM_CLIP=m
# CONFIG_ATM_CLIP_NO_ICMP is not set
CONFIG_ATM_LANE=m
# CONFIG_ATM_MPOA is not set
CONFIG_ATM_BR2684=m
# CONFIG_ATM_BR2684_IPFILTER is not set
CONFIG_L2TP=m
CONFIG_L2TP_DEBUGFS=m
CONFIG_L2TP_V3=y
CONFIG_L2TP_IP=m
CONFIG_L2TP_ETH=m
CONFIG_STP=m
CONFIG_GARP=m
CONFIG_MRP=m
CONFIG_BRIDGE=m
CONFIG_BRIDGE_IGMP_SNOOPING=y
CONFIG_BRIDGE_VLAN_FILTERING=y
CONFIG_HAVE_NET_DSA=y
# CONFIG_NET_DSA is not set
CONFIG_VLAN_8021Q=m
CONFIG_VLAN_8021Q_GVRP=y
CONFIG_VLAN_8021Q_MVRP=y
# CONFIG_DECNET is not set
CONFIG_LLC=m
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_PHONET is not set
# CONFIG_6LOWPAN is not set
CONFIG_IEEE802154=m
# CONFIG_IEEE802154_NL802154_EXPERIMENTAL is not set
CONFIG_IEEE802154_SOCKET=m
CONFIG_MAC802154=m
CONFIG_NET_SCHED=y

#
# Queueing/Scheduling
#
CONFIG_NET_SCH_CBQ=m
CONFIG_NET_SCH_HTB=m
CONFIG_NET_SCH_HFSC=m
CONFIG_NET_SCH_ATM=m
CONFIG_NET_SCH_PRIO=m
CONFIG_NET_SCH_MULTIQ=m
CONFIG_NET_SCH_RED=m
CONFIG_NET_SCH_SFB=m
CONFIG_NET_SCH_SFQ=m
CONFIG_NET_SCH_TEQL=m
CONFIG_NET_SCH_TBF=m
CONFIG_NET_SCH_GRED=m
CONFIG_NET_SCH_DSMARK=m
CONFIG_NET_SCH_NETEM=m
CONFIG_NET_SCH_DRR=m
CONFIG_NET_SCH_MQPRIO=m
CONFIG_NET_SCH_CHOKE=m
CONFIG_NET_SCH_QFQ=m
CONFIG_NET_SCH_CODEL=m
CONFIG_NET_SCH_FQ_CODEL=m
# CONFIG_NET_SCH_FQ is not set
# CONFIG_NET_SCH_HHF is not set
# CONFIG_NET_SCH_PIE is not set
CONFIG_NET_SCH_INGRESS=m
CONFIG_NET_SCH_PLUG=m
# CONFIG_NET_SCH_DEFAULT is not set

#
# Classification
#
CONFIG_NET_CLS=y
CONFIG_NET_CLS_BASIC=m
CONFIG_NET_CLS_TCINDEX=m
CONFIG_NET_CLS_ROUTE4=m
CONFIG_NET_CLS_FW=m
CONFIG_NET_CLS_U32=m
CONFIG_CLS_U32_PERF=y
CONFIG_CLS_U32_MARK=y
CONFIG_NET_CLS_RSVP=m
CONFIG_NET_CLS_RSVP6=m
CONFIG_NET_CLS_FLOW=m
CONFIG_NET_CLS_CGROUP=y
CONFIG_NET_CLS_BPF=m
# CONFIG_NET_CLS_FLOWER is not set
# CONFIG_NET_CLS_MATCHALL is not set
CONFIG_NET_EMATCH=y
CONFIG_NET_EMATCH_STACK=32
CONFIG_NET_EMATCH_CMP=m
CONFIG_NET_EMATCH_NBYTE=m
CONFIG_NET_EMATCH_U32=m
CONFIG_NET_EMATCH_META=m
CONFIG_NET_EMATCH_TEXT=m
CONFIG_NET_EMATCH_IPSET=m
CONFIG_NET_CLS_ACT=y
CONFIG_NET_ACT_POLICE=m
CONFIG_NET_ACT_GACT=m
CONFIG_GACT_PROB=y
CONFIG_NET_ACT_MIRRED=m
# CONFIG_NET_ACT_SAMPLE is not set
CONFIG_NET_ACT_IPT=m
CONFIG_NET_ACT_NAT=m
CONFIG_NET_ACT_PEDIT=m
CONFIG_NET_ACT_SIMP=m
CONFIG_NET_ACT_SKBEDIT=m
CONFIG_NET_ACT_CSUM=m
# CONFIG_NET_ACT_VLAN is not set
# CONFIG_NET_ACT_BPF is not set
# CONFIG_NET_ACT_CONNMARK is not set
# CONFIG_NET_ACT_SKBMOD is not set
# CONFIG_NET_ACT_IFE is not set
# CONFIG_NET_ACT_TUNNEL_KEY is not set
CONFIG_NET_CLS_IND=y
CONFIG_NET_SCH_FIFO=y
CONFIG_DCB=y
CONFIG_DNS_RESOLVER=m
# CONFIG_BATMAN_ADV is not set
CONFIG_OPENVSWITCH=m
CONFIG_OPENVSWITCH_GRE=m
CONFIG_OPENVSWITCH_VXLAN=m
CONFIG_VSOCKETS=m
CONFIG_VMWARE_VMCI_VSOCKETS=m
# CONFIG_VIRTIO_VSOCKETS is not set
CONFIG_NETLINK_DIAG=m
CONFIG_MPLS=y
CONFIG_NET_MPLS_GSO=m
# CONFIG_MPLS_ROUTING is not set
# CONFIG_HSR is not set
# CONFIG_NET_SWITCHDEV is not set
# CONFIG_NET_L3_MASTER_DEV is not set
# CONFIG_NET_NCSI is not set
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
# CONFIG_CGROUP_NET_PRIO is not set
CONFIG_CGROUP_NET_CLASSID=y
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y
CONFIG_BPF_JIT=y
CONFIG_NET_FLOW_LIMIT=y

#
# Network testing
#
CONFIG_NET_PKTGEN=m
# CONFIG_NET_TCPPROBE is not set
CONFIG_NET_DROP_MONITOR=y
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
# CONFIG_IRDA is not set
# CONFIG_BT is not set
# CONFIG_AF_RXRPC is not set
# CONFIG_AF_KCM is not set
# CONFIG_STREAM_PARSER is not set
CONFIG_FIB_RULES=y
CONFIG_WIRELESS=y
CONFIG_WIRELESS_EXT=y
CONFIG_WEXT_CORE=y
CONFIG_WEXT_PROC=y
CONFIG_WEXT_PRIV=y
CONFIG_CFG80211=m
# CONFIG_NL80211_TESTMODE is not set
# CONFIG_CFG80211_DEVELOPER_WARNINGS is not set
# CONFIG_CFG80211_CERTIFICATION_ONUS is not set
CONFIG_CFG80211_DEFAULT_PS=y
# CONFIG_CFG80211_DEBUGFS is not set
# CONFIG_CFG80211_INTERNAL_REGDB is not set
CONFIG_CFG80211_CRDA_SUPPORT=y
CONFIG_CFG80211_WEXT=y
CONFIG_LIB80211=m
# CONFIG_LIB80211_DEBUG is not set
CONFIG_MAC80211=m
CONFIG_MAC80211_HAS_RC=y
CONFIG_MAC80211_RC_MINSTREL=y
CONFIG_MAC80211_RC_MINSTREL_HT=y
# CONFIG_MAC80211_RC_MINSTREL_VHT is not set
CONFIG_MAC80211_RC_DEFAULT_MINSTREL=y
CONFIG_MAC80211_RC_DEFAULT="minstrel_ht"
CONFIG_MAC80211_MESH=y
CONFIG_MAC80211_LEDS=y
# CONFIG_MAC80211_DEBUGFS is not set
# CONFIG_MAC80211_MESSAGE_TRACING is not set
# CONFIG_MAC80211_DEBUG_MENU is not set
CONFIG_MAC80211_STA_HASH_MAX_SIZE=0
# CONFIG_WIMAX is not set
CONFIG_RFKILL=m
CONFIG_RFKILL_LEDS=y
CONFIG_RFKILL_INPUT=y
# CONFIG_RFKILL_GPIO is not set
CONFIG_NET_9P=y
CONFIG_NET_9P_VIRTIO=y
# CONFIG_NET_9P_DEBUG is not set
# CONFIG_CAIF is not set
# CONFIG_CEPH_LIB is not set
# CONFIG_NFC is not set
# CONFIG_PSAMPLE is not set
# CONFIG_NET_IFE is not set
# CONFIG_LWTUNNEL is not set
CONFIG_DST_CACHE=y
CONFIG_GRO_CELLS=y
# CONFIG_NET_DEVLINK is not set
CONFIG_MAY_USE_DEVLINK=y
CONFIG_HAVE_EBPF_JIT=y

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER=y
CONFIG_UEVENT_HELPER_PATH=""
CONFIG_DEVTMPFS=y
CONFIG_DEVTMPFS_MOUNT=y
CONFIG_STANDALONE=y
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
# CONFIG_FIRMWARE_IN_KERNEL is not set
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
CONFIG_FW_LOADER_USER_HELPER_FALLBACK=y
CONFIG_ALLOW_DEV_COREDUMP=y
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_DEBUG_TEST_DRIVER_REMOVE is not set
# CONFIG_TEST_ASYNC_DRIVER_PROBE is not set
CONFIG_SYS_HYPERVISOR=y
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_SPI=y
CONFIG_DMA_SHARED_BUFFER=y
# CONFIG_DMA_FENCE_TRACE is not set
CONFIG_DMA_CMA=y

#
# Default contiguous memory area size:
#
CONFIG_CMA_SIZE_MBYTES=200
CONFIG_CMA_SIZE_SEL_MBYTES=y
# CONFIG_CMA_SIZE_SEL_PERCENTAGE is not set
# CONFIG_CMA_SIZE_SEL_MIN is not set
# CONFIG_CMA_SIZE_SEL_MAX is not set
CONFIG_CMA_ALIGNMENT=8

#
# Bus devices
#
CONFIG_CONNECTOR=y
CONFIG_PROC_EVENTS=y
CONFIG_MTD=m
# CONFIG_MTD_TESTS is not set
# CONFIG_MTD_REDBOOT_PARTS is not set
# CONFIG_MTD_CMDLINE_PARTS is not set
# CONFIG_MTD_AR7_PARTS is not set

#
# User Modules And Translation Layers
#
CONFIG_MTD_BLKDEVS=m
CONFIG_MTD_BLOCK=m
# CONFIG_MTD_BLOCK_RO is not set
# CONFIG_FTL is not set
# CONFIG_NFTL is not set
# CONFIG_INFTL is not set
# CONFIG_RFD_FTL is not set
# CONFIG_SSFDC is not set
# CONFIG_SM_FTL is not set
# CONFIG_MTD_OOPS is not set
# CONFIG_MTD_SWAP is not set
# CONFIG_MTD_PARTITIONED_MASTER is not set

#
# RAM/ROM/Flash chip drivers
#
# CONFIG_MTD_CFI is not set
# CONFIG_MTD_JEDECPROBE is not set
CONFIG_MTD_MAP_BANK_WIDTH_1=y
CONFIG_MTD_MAP_BANK_WIDTH_2=y
CONFIG_MTD_MAP_BANK_WIDTH_4=y
# CONFIG_MTD_MAP_BANK_WIDTH_8 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_16 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_32 is not set
CONFIG_MTD_CFI_I1=y
CONFIG_MTD_CFI_I2=y
# CONFIG_MTD_CFI_I4 is not set
# CONFIG_MTD_CFI_I8 is not set
# CONFIG_MTD_RAM is not set
# CONFIG_MTD_ROM is not set
# CONFIG_MTD_ABSENT is not set

#
# Mapping drivers for chip access
#
# CONFIG_MTD_COMPLEX_MAPPINGS is not set
# CONFIG_MTD_INTEL_VR_NOR is not set
# CONFIG_MTD_PLATRAM is not set

#
# Self-contained MTD device drivers
#
# CONFIG_MTD_PMC551 is not set
# CONFIG_MTD_DATAFLASH is not set
# CONFIG_MTD_SST25L is not set
# CONFIG_MTD_SLRAM is not set
# CONFIG_MTD_PHRAM is not set
# CONFIG_MTD_MTDRAM is not set
# CONFIG_MTD_BLOCK2MTD is not set

#
# Disk-On-Chip Device Drivers
#
# CONFIG_MTD_DOCG3 is not set
# CONFIG_MTD_NAND is not set
# CONFIG_MTD_ONENAND is not set

#
# LPDDR & LPDDR2 PCM memory drivers
#
# CONFIG_MTD_LPDDR is not set
# CONFIG_MTD_SPI_NOR is not set
CONFIG_MTD_UBI=m
CONFIG_MTD_UBI_WL_THRESHOLD=4096
CONFIG_MTD_UBI_BEB_LIMIT=20
# CONFIG_MTD_UBI_FASTMAP is not set
# CONFIG_MTD_UBI_GLUEBI is not set
# CONFIG_MTD_UBI_BLOCK is not set
# CONFIG_OF is not set
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PARPORT=m
CONFIG_PARPORT_PC=m
CONFIG_PARPORT_SERIAL=m
# CONFIG_PARPORT_PC_FIFO is not set
# CONFIG_PARPORT_PC_SUPERIO is not set
# CONFIG_PARPORT_GSC is not set
# CONFIG_PARPORT_AX88796 is not set
CONFIG_PARPORT_1284=y
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
# CONFIG_PNP_DEBUG_MESSAGES is not set

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
CONFIG_BLK_DEV_NULL_BLK=m
CONFIG_BLK_DEV_FD=m
# CONFIG_PARIDE is not set
CONFIG_BLK_DEV_PCIESSD_MTIP32XX=m
# CONFIG_ZRAM is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=m
CONFIG_BLK_DEV_LOOP_MIN_COUNT=0
# CONFIG_BLK_DEV_CRYPTOLOOP is not set
# CONFIG_BLK_DEV_DRBD is not set
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_SKD is not set
CONFIG_BLK_DEV_OSD=m
CONFIG_BLK_DEV_SX8=m
CONFIG_BLK_DEV_RAM=m
CONFIG_BLK_DEV_RAM_COUNT=16
CONFIG_BLK_DEV_RAM_SIZE=16384
# CONFIG_BLK_DEV_RAM_DAX is not set
CONFIG_CDROM_PKTCDVD=m
CONFIG_CDROM_PKTCDVD_BUFFERS=8
# CONFIG_CDROM_PKTCDVD_WCACHE is not set
CONFIG_ATA_OVER_ETH=m
CONFIG_XEN_BLKDEV_FRONTEND=m
# CONFIG_XEN_BLKDEV_BACKEND is not set
CONFIG_VIRTIO_BLK=y
# CONFIG_VIRTIO_BLK_SCSI is not set
# CONFIG_BLK_DEV_HD is not set
# CONFIG_BLK_DEV_RBD is not set
CONFIG_BLK_DEV_RSXX=m
CONFIG_NVME_CORE=m
CONFIG_BLK_DEV_NVME=m
# CONFIG_BLK_DEV_NVME_SCSI is not set
# CONFIG_NVME_FC is not set
# CONFIG_NVME_TARGET is not set

#
# Misc devices
#
CONFIG_SENSORS_LIS3LV02D=m
# CONFIG_AD525X_DPOT is not set
# CONFIG_DUMMY_IRQ is not set
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
CONFIG_SGI_IOC4=m
CONFIG_TIFM_CORE=m
CONFIG_TIFM_7XX1=m
# CONFIG_ICS932S401 is not set
CONFIG_ENCLOSURE_SERVICES=m
CONFIG_SGI_XP=m
CONFIG_HP_ILO=m
CONFIG_SGI_GRU=m
# CONFIG_SGI_GRU_DEBUG is not set
CONFIG_APDS9802ALS=m
CONFIG_ISL29003=m
CONFIG_ISL29020=m
CONFIG_SENSORS_TSL2550=m
CONFIG_SENSORS_BH1770=m
CONFIG_SENSORS_APDS990X=m
# CONFIG_HMC6352 is not set
# CONFIG_DS1682 is not set
# CONFIG_TI_DAC7512 is not set
CONFIG_VMWARE_BALLOON=m
# CONFIG_USB_SWITCH_FSA9480 is not set
# CONFIG_LATTICE_ECP3_CONFIG is not set
# CONFIG_SRAM is not set
# CONFIG_PANEL is not set
# CONFIG_C2PORT is not set

#
# EEPROM support
#
CONFIG_EEPROM_AT24=m
# CONFIG_EEPROM_AT25 is not set
CONFIG_EEPROM_LEGACY=m
CONFIG_EEPROM_MAX6875=m
CONFIG_EEPROM_93CX6=m
# CONFIG_EEPROM_93XX46 is not set
# CONFIG_EEPROM_IDT_89HPESX is not set
CONFIG_CB710_CORE=m
# CONFIG_CB710_DEBUG is not set
CONFIG_CB710_DEBUG_ASSUMPTIONS=y

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
CONFIG_SENSORS_LIS3_I2C=m

#
# Altera FPGA firmware download module
#
CONFIG_ALTERA_STAPL=m
CONFIG_INTEL_MEI=y
CONFIG_INTEL_MEI_ME=y
# CONFIG_INTEL_MEI_TXE is not set
CONFIG_VMWARE_VMCI=m

#
# Intel MIC Bus Driver
#
# CONFIG_INTEL_MIC_BUS is not set

#
# SCIF Bus Driver
#
# CONFIG_SCIF_BUS is not set

#
# VOP Bus Driver
#
# CONFIG_VOP_BUS is not set

#
# Intel MIC Host Driver
#

#
# Intel MIC Card Driver
#

#
# SCIF Driver
#

#
# Intel MIC Coprocessor State Management (COSM) Drivers
#

#
# VOP Driver
#
# CONFIG_GENWQE is not set
# CONFIG_ECHO is not set
# CONFIG_CXL_BASE is not set
# CONFIG_CXL_AFU_DRIVER_OPS is not set
CONFIG_HAVE_IDE=y
# CONFIG_IDE is not set

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=m
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
CONFIG_SCSI_NETLINK=y
# CONFIG_SCSI_MQ_DEFAULT is not set
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=m
CONFIG_CHR_DEV_ST=m
CONFIG_CHR_DEV_OSST=m
CONFIG_BLK_DEV_SR=m
CONFIG_BLK_DEV_SR_VENDOR=y
CONFIG_CHR_DEV_SG=m
CONFIG_CHR_DEV_SCH=m
CONFIG_SCSI_ENCLOSURE=m
CONFIG_SCSI_CONSTANTS=y
CONFIG_SCSI_LOGGING=y
CONFIG_SCSI_SCAN_ASYNC=y

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=m
CONFIG_SCSI_FC_ATTRS=m
CONFIG_SCSI_ISCSI_ATTRS=m
CONFIG_SCSI_SAS_ATTRS=m
CONFIG_SCSI_SAS_LIBSAS=m
CONFIG_SCSI_SAS_ATA=y
CONFIG_SCSI_SAS_HOST_SMP=y
CONFIG_SCSI_SRP_ATTRS=m
CONFIG_SCSI_LOWLEVEL=y
CONFIG_ISCSI_TCP=m
CONFIG_ISCSI_BOOT_SYSFS=m
CONFIG_SCSI_CXGB3_ISCSI=m
CONFIG_SCSI_CXGB4_ISCSI=m
CONFIG_SCSI_BNX2_ISCSI=m
CONFIG_SCSI_BNX2X_FCOE=m
CONFIG_BE2ISCSI=m
# CONFIG_BLK_DEV_3W_XXXX_RAID is not set
CONFIG_SCSI_HPSA=m
CONFIG_SCSI_3W_9XXX=m
CONFIG_SCSI_3W_SAS=m
# CONFIG_SCSI_ACARD is not set
CONFIG_SCSI_AACRAID=m
# CONFIG_SCSI_AIC7XXX is not set
CONFIG_SCSI_AIC79XX=m
CONFIG_AIC79XX_CMDS_PER_DEVICE=4
CONFIG_AIC79XX_RESET_DELAY_MS=15000
# CONFIG_AIC79XX_DEBUG_ENABLE is not set
CONFIG_AIC79XX_DEBUG_MASK=0
# CONFIG_AIC79XX_REG_PRETTY_PRINT is not set
# CONFIG_SCSI_AIC94XX is not set
CONFIG_SCSI_MVSAS=m
# CONFIG_SCSI_MVSAS_DEBUG is not set
CONFIG_SCSI_MVSAS_TASKLET=y
CONFIG_SCSI_MVUMI=m
# CONFIG_SCSI_DPT_I2O is not set
# CONFIG_SCSI_ADVANSYS is not set
CONFIG_SCSI_ARCMSR=m
# CONFIG_SCSI_ESAS2R is not set
# CONFIG_MEGARAID_NEWGEN is not set
# CONFIG_MEGARAID_LEGACY is not set
CONFIG_MEGARAID_SAS=m
CONFIG_SCSI_MPT3SAS=m
CONFIG_SCSI_MPT2SAS_MAX_SGE=128
CONFIG_SCSI_MPT3SAS_MAX_SGE=128
CONFIG_SCSI_MPT2SAS=m
# CONFIG_SCSI_SMARTPQI is not set
CONFIG_SCSI_UFSHCD=m
CONFIG_SCSI_UFSHCD_PCI=m
# CONFIG_SCSI_UFS_DWC_TC_PCI is not set
# CONFIG_SCSI_UFSHCD_PLATFORM is not set
CONFIG_SCSI_HPTIOP=m
# CONFIG_SCSI_BUSLOGIC is not set
CONFIG_VMWARE_PVSCSI=m
# CONFIG_XEN_SCSI_FRONTEND is not set
CONFIG_HYPERV_STORAGE=m
CONFIG_LIBFC=m
CONFIG_LIBFCOE=m
CONFIG_FCOE=m
CONFIG_FCOE_FNIC=m
# CONFIG_SCSI_SNIC is not set
# CONFIG_SCSI_DMX3191D is not set
# CONFIG_SCSI_EATA is not set
# CONFIG_SCSI_FUTURE_DOMAIN is not set
# CONFIG_SCSI_GDTH is not set
CONFIG_SCSI_ISCI=m
# CONFIG_SCSI_IPS is not set
CONFIG_SCSI_INITIO=m
# CONFIG_SCSI_INIA100 is not set
# CONFIG_SCSI_PPA is not set
# CONFIG_SCSI_IMM is not set
CONFIG_SCSI_STEX=m
# CONFIG_SCSI_SYM53C8XX_2 is not set
CONFIG_SCSI_IPR=m
CONFIG_SCSI_IPR_TRACE=y
CONFIG_SCSI_IPR_DUMP=y
# CONFIG_SCSI_QLOGIC_1280 is not set
CONFIG_SCSI_QLA_FC=m
# CONFIG_TCM_QLA2XXX is not set
CONFIG_SCSI_QLA_ISCSI=m
# CONFIG_SCSI_LPFC is not set
# CONFIG_SCSI_DC395x is not set
# CONFIG_SCSI_AM53C974 is not set
# CONFIG_SCSI_WD719X is not set
CONFIG_SCSI_DEBUG=m
CONFIG_SCSI_PMCRAID=m
CONFIG_SCSI_PM8001=m
# CONFIG_SCSI_BFA_FC is not set
CONFIG_SCSI_VIRTIO=m
CONFIG_SCSI_CHELSIO_FCOE=m
CONFIG_SCSI_DH=y
CONFIG_SCSI_DH_RDAC=y
CONFIG_SCSI_DH_HP_SW=y
CONFIG_SCSI_DH_EMC=y
CONFIG_SCSI_DH_ALUA=y
CONFIG_SCSI_OSD_INITIATOR=m
CONFIG_SCSI_OSD_ULD=m
CONFIG_SCSI_OSD_DPRINT_SENSE=1
# CONFIG_SCSI_OSD_DEBUG is not set
CONFIG_ATA=m
# CONFIG_ATA_NONSTANDARD is not set
CONFIG_ATA_VERBOSE_ERROR=y
CONFIG_ATA_ACPI=y
# CONFIG_SATA_ZPODD is not set
CONFIG_SATA_PMP=y

#
# Controllers with non-SFF native interface
#
CONFIG_SATA_AHCI=m
CONFIG_SATA_AHCI_PLATFORM=m
# CONFIG_SATA_INIC162X is not set
CONFIG_SATA_ACARD_AHCI=m
CONFIG_SATA_SIL24=m
CONFIG_ATA_SFF=y

#
# SFF controllers with custom DMA interface
#
CONFIG_PDC_ADMA=m
CONFIG_SATA_QSTOR=m
CONFIG_SATA_SX4=m
CONFIG_ATA_BMDMA=y

#
# SATA SFF controllers with BMDMA
#
CONFIG_ATA_PIIX=m
# CONFIG_SATA_DWC is not set
CONFIG_SATA_MV=m
CONFIG_SATA_NV=m
CONFIG_SATA_PROMISE=m
CONFIG_SATA_SIL=m
CONFIG_SATA_SIS=m
CONFIG_SATA_SVW=m
CONFIG_SATA_ULI=m
CONFIG_SATA_VIA=m
CONFIG_SATA_VITESSE=m

#
# PATA SFF controllers with BMDMA
#
CONFIG_PATA_ALI=m
CONFIG_PATA_AMD=m
CONFIG_PATA_ARTOP=m
CONFIG_PATA_ATIIXP=m
CONFIG_PATA_ATP867X=m
CONFIG_PATA_CMD64X=m
# CONFIG_PATA_CYPRESS is not set
# CONFIG_PATA_EFAR is not set
CONFIG_PATA_HPT366=m
CONFIG_PATA_HPT37X=m
CONFIG_PATA_HPT3X2N=m
CONFIG_PATA_HPT3X3=m
# CONFIG_PATA_HPT3X3_DMA is not set
CONFIG_PATA_IT8213=m
CONFIG_PATA_IT821X=m
CONFIG_PATA_JMICRON=m
CONFIG_PATA_MARVELL=m
CONFIG_PATA_NETCELL=m
CONFIG_PATA_NINJA32=m
# CONFIG_PATA_NS87415 is not set
CONFIG_PATA_OLDPIIX=m
# CONFIG_PATA_OPTIDMA is not set
CONFIG_PATA_PDC2027X=m
CONFIG_PATA_PDC_OLD=m
# CONFIG_PATA_RADISYS is not set
CONFIG_PATA_RDC=m
CONFIG_PATA_SCH=m
CONFIG_PATA_SERVERWORKS=m
CONFIG_PATA_SIL680=m
CONFIG_PATA_SIS=m
CONFIG_PATA_TOSHIBA=m
# CONFIG_PATA_TRIFLEX is not set
CONFIG_PATA_VIA=m
# CONFIG_PATA_WINBOND is not set

#
# PIO-only SFF controllers
#
# CONFIG_PATA_CMD640_PCI is not set
# CONFIG_PATA_MPIIX is not set
# CONFIG_PATA_NS87410 is not set
# CONFIG_PATA_OPTI is not set
# CONFIG_PATA_PLATFORM is not set
# CONFIG_PATA_RZ1000 is not set

#
# Generic fallback / legacy drivers
#
CONFIG_PATA_ACPI=m
CONFIG_ATA_GENERIC=m
# CONFIG_PATA_LEGACY is not set
CONFIG_MD=y
CONFIG_BLK_DEV_MD=y
CONFIG_MD_AUTODETECT=y
CONFIG_MD_LINEAR=m
CONFIG_MD_RAID0=m
CONFIG_MD_RAID1=m
CONFIG_MD_RAID10=m
CONFIG_MD_RAID456=m
CONFIG_MD_MULTIPATH=m
CONFIG_MD_FAULTY=m
# CONFIG_MD_CLUSTER is not set
# CONFIG_BCACHE is not set
CONFIG_BLK_DEV_DM_BUILTIN=y
CONFIG_BLK_DEV_DM=m
# CONFIG_DM_MQ_DEFAULT is not set
CONFIG_DM_DEBUG=y
CONFIG_DM_BUFIO=m
# CONFIG_DM_DEBUG_BLOCK_MANAGER_LOCKING is not set
CONFIG_DM_BIO_PRISON=m
CONFIG_DM_PERSISTENT_DATA=m
CONFIG_DM_CRYPT=m
CONFIG_DM_SNAPSHOT=m
CONFIG_DM_THIN_PROVISIONING=m
CONFIG_DM_CACHE=m
CONFIG_DM_CACHE_SMQ=m
CONFIG_DM_CACHE_CLEANER=m
# CONFIG_DM_ERA is not set
CONFIG_DM_MIRROR=m
CONFIG_DM_LOG_USERSPACE=m
CONFIG_DM_RAID=m
CONFIG_DM_ZERO=m
CONFIG_DM_MULTIPATH=m
CONFIG_DM_MULTIPATH_QL=m
CONFIG_DM_MULTIPATH_ST=m
CONFIG_DM_DELAY=m
CONFIG_DM_UEVENT=y
CONFIG_DM_FLAKEY=m
CONFIG_DM_VERITY=m
# CONFIG_DM_VERITY_FEC is not set
CONFIG_DM_SWITCH=m
# CONFIG_DM_LOG_WRITES is not set
CONFIG_TARGET_CORE=m
CONFIG_TCM_IBLOCK=m
CONFIG_TCM_FILEIO=m
CONFIG_TCM_PSCSI=m
# CONFIG_TCM_USER2 is not set
CONFIG_LOOPBACK_TARGET=m
CONFIG_TCM_FC=m
CONFIG_ISCSI_TARGET=m
# CONFIG_ISCSI_TARGET_CXGB4 is not set
# CONFIG_SBP_TARGET is not set
CONFIG_FUSION=y
CONFIG_FUSION_SPI=m
# CONFIG_FUSION_FC is not set
CONFIG_FUSION_SAS=m
CONFIG_FUSION_MAX_SGE=128
CONFIG_FUSION_CTL=m
CONFIG_FUSION_LOGGING=y

#
# IEEE 1394 (FireWire) support
#
CONFIG_FIREWIRE=m
CONFIG_FIREWIRE_OHCI=m
CONFIG_FIREWIRE_SBP2=m
CONFIG_FIREWIRE_NET=m
# CONFIG_FIREWIRE_NOSY is not set
CONFIG_MACINTOSH_DRIVERS=y
CONFIG_MAC_EMUMOUSEBTN=y
CONFIG_NETDEVICES=y
CONFIG_MII=y
CONFIG_NET_CORE=y
CONFIG_BONDING=m
CONFIG_DUMMY=m
# CONFIG_EQUALIZER is not set
CONFIG_NET_FC=y
CONFIG_IFB=m
CONFIG_NET_TEAM=m
CONFIG_NET_TEAM_MODE_BROADCAST=m
CONFIG_NET_TEAM_MODE_ROUNDROBIN=m
CONFIG_NET_TEAM_MODE_RANDOM=m
CONFIG_NET_TEAM_MODE_ACTIVEBACKUP=m
CONFIG_NET_TEAM_MODE_LOADBALANCE=m
CONFIG_MACVLAN=m
CONFIG_MACVTAP=m
CONFIG_VXLAN=m
# CONFIG_GENEVE is not set
# CONFIG_GTP is not set
# CONFIG_MACSEC is not set
CONFIG_NETCONSOLE=m
CONFIG_NETCONSOLE_DYNAMIC=y
CONFIG_NETPOLL=y
CONFIG_NET_POLL_CONTROLLER=y
CONFIG_TUN=m
CONFIG_TAP=m
# CONFIG_TUN_VNET_CROSS_LE is not set
CONFIG_VETH=m
CONFIG_VIRTIO_NET=y
CONFIG_NLMON=m
# CONFIG_ARCNET is not set
# CONFIG_ATM_DRIVERS is not set

#
# CAIF transport drivers
#

#
# Distributed Switch Architecture drivers
#
CONFIG_ETHERNET=y
CONFIG_MDIO=y
# CONFIG_NET_VENDOR_3COM is not set
# CONFIG_NET_VENDOR_ADAPTEC is not set
CONFIG_NET_VENDOR_AGERE=y
# CONFIG_ET131X is not set
CONFIG_NET_VENDOR_ALACRITECH=y
# CONFIG_SLICOSS is not set
# CONFIG_NET_VENDOR_ALTEON is not set
# CONFIG_ALTERA_TSE is not set
CONFIG_NET_VENDOR_AMAZON=y
# CONFIG_ENA_ETHERNET is not set
# CONFIG_NET_VENDOR_AMD is not set
CONFIG_NET_VENDOR_AQUANTIA=y
# CONFIG_AQTION is not set
CONFIG_NET_VENDOR_ARC=y
CONFIG_NET_VENDOR_ATHEROS=y
CONFIG_ATL2=m
CONFIG_ATL1=m
CONFIG_ATL1E=m
CONFIG_ATL1C=m
CONFIG_ALX=m
# CONFIG_NET_VENDOR_AURORA is not set
CONFIG_NET_CADENCE=y
# CONFIG_MACB is not set
CONFIG_NET_VENDOR_BROADCOM=y
CONFIG_B44=m
CONFIG_B44_PCI_AUTOSELECT=y
CONFIG_B44_PCICORE_AUTOSELECT=y
CONFIG_B44_PCI=y
# CONFIG_BCMGENET is not set
CONFIG_BNX2=m
CONFIG_CNIC=m
CONFIG_TIGON3=y
CONFIG_TIGON3_HWMON=y
# CONFIG_BNX2X is not set
# CONFIG_BNXT is not set
CONFIG_NET_VENDOR_BROCADE=y
CONFIG_BNA=m
CONFIG_NET_VENDOR_CAVIUM=y
# CONFIG_THUNDER_NIC_PF is not set
# CONFIG_THUNDER_NIC_VF is not set
# CONFIG_THUNDER_NIC_BGX is not set
# CONFIG_THUNDER_NIC_RGX is not set
# CONFIG_LIQUIDIO is not set
# CONFIG_LIQUIDIO_VF is not set
CONFIG_NET_VENDOR_CHELSIO=y
# CONFIG_CHELSIO_T1 is not set
CONFIG_CHELSIO_T3=m
CONFIG_CHELSIO_T4=m
# CONFIG_CHELSIO_T4_DCB is not set
CONFIG_CHELSIO_T4VF=m
CONFIG_CHELSIO_LIB=m
CONFIG_NET_VENDOR_CISCO=y
CONFIG_ENIC=m
# CONFIG_CX_ECAT is not set
CONFIG_DNET=m
CONFIG_NET_VENDOR_DEC=y
CONFIG_NET_TULIP=y
CONFIG_DE2104X=m
CONFIG_DE2104X_DSL=0
CONFIG_TULIP=y
# CONFIG_TULIP_MWI is not set
CONFIG_TULIP_MMIO=y
# CONFIG_TULIP_NAPI is not set
CONFIG_DE4X5=m
CONFIG_WINBOND_840=m
CONFIG_DM9102=m
CONFIG_ULI526X=m
CONFIG_PCMCIA_XIRCOM=m
# CONFIG_NET_VENDOR_DLINK is not set
CONFIG_NET_VENDOR_EMULEX=y
CONFIG_BE2NET=m
CONFIG_BE2NET_HWMON=y
CONFIG_NET_VENDOR_EZCHIP=y
# CONFIG_NET_VENDOR_EXAR is not set
# CONFIG_NET_VENDOR_HP is not set
CONFIG_NET_VENDOR_INTEL=y
# CONFIG_E100 is not set
CONFIG_E1000=y
CONFIG_E1000E=y
CONFIG_E1000E_HWTS=y
CONFIG_IGB=y
CONFIG_IGB_HWMON=y
CONFIG_IGBVF=m
CONFIG_IXGB=m
CONFIG_IXGBE=y
CONFIG_IXGBE_HWMON=y
CONFIG_IXGBE_DCB=y
CONFIG_IXGBEVF=m
CONFIG_I40E=m
# CONFIG_I40E_DCB is not set
# CONFIG_I40EVF is not set
# CONFIG_FM10K is not set
# CONFIG_NET_VENDOR_I825XX is not set
CONFIG_JME=m
CONFIG_NET_VENDOR_MARVELL=y
CONFIG_MVMDIO=m
CONFIG_SKGE=m
CONFIG_SKGE_DEBUG=y
CONFIG_SKGE_GENESIS=y
CONFIG_SKY2=m
CONFIG_SKY2_DEBUG=y
CONFIG_NET_VENDOR_MELLANOX=y
CONFIG_MLX4_EN=m
CONFIG_MLX4_EN_DCB=y
CONFIG_MLX4_CORE=m
CONFIG_MLX4_DEBUG=y
# CONFIG_MLX5_CORE is not set
# CONFIG_MLXSW_CORE is not set
# CONFIG_NET_VENDOR_MICREL is not set
CONFIG_NET_VENDOR_MICROCHIP=y
# CONFIG_ENC28J60 is not set
# CONFIG_ENCX24J600 is not set
CONFIG_NET_VENDOR_MYRI=y
CONFIG_MYRI10GE=m
# CONFIG_FEALNX is not set
# CONFIG_NET_VENDOR_NATSEMI is not set
CONFIG_NET_VENDOR_NETRONOME=y
# CONFIG_NFP is not set
# CONFIG_NET_VENDOR_NVIDIA is not set
CONFIG_NET_VENDOR_OKI=y
CONFIG_ETHOC=m
CONFIG_NET_PACKET_ENGINE=y
# CONFIG_HAMACHI is not set
CONFIG_YELLOWFIN=m
CONFIG_NET_VENDOR_QLOGIC=y
CONFIG_QLA3XXX=m
CONFIG_QLCNIC=m
CONFIG_QLCNIC_SRIOV=y
CONFIG_QLCNIC_DCB=y
CONFIG_QLCNIC_HWMON=y
CONFIG_QLGE=m
CONFIG_NETXEN_NIC=m
# CONFIG_QED is not set
CONFIG_NET_VENDOR_QUALCOMM=y
# CONFIG_QCOM_EMAC is not set
CONFIG_NET_VENDOR_REALTEK=y
# CONFIG_ATP is not set
CONFIG_8139CP=y
CONFIG_8139TOO=y
CONFIG_8139TOO_PIO=y
# CONFIG_8139TOO_TUNE_TWISTER is not set
CONFIG_8139TOO_8129=y
# CONFIG_8139_OLD_RX_RESET is not set
CONFIG_R8169=y
CONFIG_NET_VENDOR_RENESAS=y
# CONFIG_NET_VENDOR_RDC is not set
CONFIG_NET_VENDOR_ROCKER=y
CONFIG_NET_VENDOR_SAMSUNG=y
# CONFIG_SXGBE_ETH is not set
# CONFIG_NET_VENDOR_SEEQ is not set
# CONFIG_NET_VENDOR_SILAN is not set
# CONFIG_NET_VENDOR_SIS is not set
CONFIG_NET_VENDOR_SOLARFLARE=y
CONFIG_SFC=m
CONFIG_SFC_MTD=y
CONFIG_SFC_MCDI_MON=y
CONFIG_SFC_SRIOV=y
CONFIG_SFC_MCDI_LOGGING=y
# CONFIG_SFC_FALCON is not set
CONFIG_NET_VENDOR_SMSC=y
CONFIG_EPIC100=m
# CONFIG_SMSC911X is not set
CONFIG_SMSC9420=m
# CONFIG_NET_VENDOR_STMICRO is not set
# CONFIG_NET_VENDOR_SUN is not set
# CONFIG_NET_VENDOR_TEHUTI is not set
# CONFIG_NET_VENDOR_TI is not set
# CONFIG_NET_VENDOR_VIA is not set
# CONFIG_NET_VENDOR_WIZNET is not set
CONFIG_NET_VENDOR_SYNOPSYS=y
# CONFIG_DWC_XLGMAC is not set
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
# CONFIG_NET_SB1000 is not set
CONFIG_MDIO_DEVICE=y
CONFIG_MDIO_BITBANG=m
# CONFIG_MDIO_GPIO is not set
# CONFIG_MDIO_OCTEON is not set
# CONFIG_MDIO_THUNDER is not set
CONFIG_PHYLIB=y
CONFIG_SWPHY=y
# CONFIG_LED_TRIGGER_PHY is not set

#
# MII PHY device drivers
#
CONFIG_AMD_PHY=m
# CONFIG_AQUANTIA_PHY is not set
CONFIG_AT803X_PHY=m
# CONFIG_BCM7XXX_PHY is not set
CONFIG_BCM87XX_PHY=m
CONFIG_BCM_NET_PHYLIB=m
CONFIG_BROADCOM_PHY=m
CONFIG_CICADA_PHY=m
CONFIG_DAVICOM_PHY=m
# CONFIG_DP83848_PHY is not set
# CONFIG_DP83867_PHY is not set
CONFIG_FIXED_PHY=y
CONFIG_ICPLUS_PHY=m
# CONFIG_INTEL_XWAY_PHY is not set
CONFIG_LSI_ET1011C_PHY=m
CONFIG_LXT_PHY=m
CONFIG_MARVELL_PHY=m
CONFIG_MICREL_PHY=m
# CONFIG_MICROCHIP_PHY is not set
# CONFIG_MICROSEMI_PHY is not set
CONFIG_NATIONAL_PHY=m
CONFIG_QSEMI_PHY=m
CONFIG_REALTEK_PHY=m
CONFIG_SMSC_PHY=m
CONFIG_STE10XP=m
# CONFIG_TERANETICS_PHY is not set
CONFIG_VITESSE_PHY=m
# CONFIG_XILINX_GMII2RGMII is not set
# CONFIG_MICREL_KS8995MA is not set
# CONFIG_PLIP is not set
CONFIG_PPP=m
CONFIG_PPP_BSDCOMP=m
CONFIG_PPP_DEFLATE=m
CONFIG_PPP_FILTER=y
CONFIG_PPP_MPPE=m
CONFIG_PPP_MULTILINK=y
CONFIG_PPPOATM=m
CONFIG_PPPOE=m
CONFIG_PPTP=m
CONFIG_PPPOL2TP=m
CONFIG_PPP_ASYNC=m
CONFIG_PPP_SYNC_TTY=m
CONFIG_SLIP=m
CONFIG_SLHC=m
CONFIG_SLIP_COMPRESSED=y
CONFIG_SLIP_SMART=y
# CONFIG_SLIP_MODE_SLIP6 is not set
CONFIG_USB_NET_DRIVERS=y
CONFIG_USB_CATC=y
CONFIG_USB_KAWETH=y
CONFIG_USB_PEGASUS=y
CONFIG_USB_RTL8150=y
CONFIG_USB_RTL8152=m
# CONFIG_USB_LAN78XX is not set
CONFIG_USB_USBNET=y
CONFIG_USB_NET_AX8817X=y
CONFIG_USB_NET_AX88179_178A=m
CONFIG_USB_NET_CDCETHER=y
CONFIG_USB_NET_CDC_EEM=y
CONFIG_USB_NET_CDC_NCM=m
# CONFIG_USB_NET_HUAWEI_CDC_NCM is not set
CONFIG_USB_NET_CDC_MBIM=m
CONFIG_USB_NET_DM9601=y
# CONFIG_USB_NET_SR9700 is not set
# CONFIG_USB_NET_SR9800 is not set
CONFIG_USB_NET_SMSC75XX=y
CONFIG_USB_NET_SMSC95XX=y
CONFIG_USB_NET_GL620A=y
CONFIG_USB_NET_NET1080=y
CONFIG_USB_NET_PLUSB=y
CONFIG_USB_NET_MCS7830=y
CONFIG_USB_NET_RNDIS_HOST=y
CONFIG_USB_NET_CDC_SUBSET_ENABLE=y
CONFIG_USB_NET_CDC_SUBSET=y
CONFIG_USB_ALI_M5632=y
CONFIG_USB_AN2720=y
CONFIG_USB_BELKIN=y
CONFIG_USB_ARMLINUX=y
CONFIG_USB_EPSON2888=y
CONFIG_USB_KC2190=y
CONFIG_USB_NET_ZAURUS=y
CONFIG_USB_NET_CX82310_ETH=m
CONFIG_USB_NET_KALMIA=m
CONFIG_USB_NET_QMI_WWAN=m
CONFIG_USB_HSO=m
CONFIG_USB_NET_INT51X1=y
CONFIG_USB_IPHETH=y
CONFIG_USB_SIERRA_NET=y
CONFIG_USB_VL600=m
# CONFIG_USB_NET_CH9200 is not set
CONFIG_WLAN=y
# CONFIG_WIRELESS_WDS is not set
CONFIG_WLAN_VENDOR_ADMTEK=y
# CONFIG_ADM8211 is not set
CONFIG_WLAN_VENDOR_ATH=y
# CONFIG_ATH_DEBUG is not set
# CONFIG_ATH5K is not set
# CONFIG_ATH5K_PCI is not set
# CONFIG_ATH9K is not set
# CONFIG_ATH9K_HTC is not set
# CONFIG_CARL9170 is not set
# CONFIG_ATH6KL is not set
# CONFIG_AR5523 is not set
# CONFIG_WIL6210 is not set
# CONFIG_ATH10K is not set
# CONFIG_WCN36XX is not set
CONFIG_WLAN_VENDOR_ATMEL=y
# CONFIG_ATMEL is not set
# CONFIG_AT76C50X_USB is not set
CONFIG_WLAN_VENDOR_BROADCOM=y
# CONFIG_B43 is not set
# CONFIG_B43LEGACY is not set
# CONFIG_BRCMSMAC is not set
# CONFIG_BRCMFMAC is not set
CONFIG_WLAN_VENDOR_CISCO=y
# CONFIG_AIRO is not set
CONFIG_WLAN_VENDOR_INTEL=y
# CONFIG_IPW2100 is not set
# CONFIG_IPW2200 is not set
# CONFIG_IWL4965 is not set
# CONFIG_IWL3945 is not set
# CONFIG_IWLWIFI is not set
CONFIG_WLAN_VENDOR_INTERSIL=y
# CONFIG_HOSTAP is not set
# CONFIG_HERMES is not set
# CONFIG_P54_COMMON is not set
# CONFIG_PRISM54 is not set
CONFIG_WLAN_VENDOR_MARVELL=y
# CONFIG_LIBERTAS is not set
# CONFIG_LIBERTAS_THINFIRM is not set
# CONFIG_MWIFIEX is not set
# CONFIG_MWL8K is not set
CONFIG_WLAN_VENDOR_MEDIATEK=y
# CONFIG_MT7601U is not set
CONFIG_WLAN_VENDOR_RALINK=y
# CONFIG_RT2X00 is not set
CONFIG_WLAN_VENDOR_REALTEK=y
# CONFIG_RTL8180 is not set
# CONFIG_RTL8187 is not set
CONFIG_RTL_CARDS=m
# CONFIG_RTL8192CE is not set
# CONFIG_RTL8192SE is not set
# CONFIG_RTL8192DE is not set
# CONFIG_RTL8723AE is not set
# CONFIG_RTL8723BE is not set
# CONFIG_RTL8188EE is not set
# CONFIG_RTL8192EE is not set
# CONFIG_RTL8821AE is not set
# CONFIG_RTL8192CU is not set
# CONFIG_RTL8XXXU is not set
CONFIG_WLAN_VENDOR_RSI=y
# CONFIG_RSI_91X is not set
CONFIG_WLAN_VENDOR_ST=y
# CONFIG_CW1200 is not set
CONFIG_WLAN_VENDOR_TI=y
# CONFIG_WL1251 is not set
# CONFIG_WL12XX is not set
# CONFIG_WL18XX is not set
# CONFIG_WLCORE is not set
CONFIG_WLAN_VENDOR_ZYDAS=y
# CONFIG_USB_ZD1201 is not set
# CONFIG_ZD1211RW is not set
CONFIG_MAC80211_HWSIM=m
# CONFIG_USB_NET_RNDIS_WLAN is not set

#
# Enable WiMAX (Networking options) to see the WiMAX drivers
#
CONFIG_WAN=y
# CONFIG_LANMEDIA is not set
CONFIG_HDLC=m
CONFIG_HDLC_RAW=m
# CONFIG_HDLC_RAW_ETH is not set
CONFIG_HDLC_CISCO=m
CONFIG_HDLC_FR=m
CONFIG_HDLC_PPP=m

#
# X.25/LAPB support is disabled
#
# CONFIG_PCI200SYN is not set
# CONFIG_WANXL is not set
# CONFIG_PC300TOO is not set
# CONFIG_FARSYNC is not set
# CONFIG_DSCC4 is not set
CONFIG_DLCI=m
CONFIG_DLCI_MAX=8
# CONFIG_SBNI is not set
CONFIG_IEEE802154_DRIVERS=m
CONFIG_IEEE802154_FAKELB=m
# CONFIG_IEEE802154_AT86RF230 is not set
# CONFIG_IEEE802154_MRF24J40 is not set
# CONFIG_IEEE802154_CC2520 is not set
# CONFIG_IEEE802154_ATUSB is not set
# CONFIG_IEEE802154_ADF7242 is not set
# CONFIG_IEEE802154_CA8210 is not set
CONFIG_XEN_NETDEV_FRONTEND=m
# CONFIG_XEN_NETDEV_BACKEND is not set
CONFIG_VMXNET3=m
# CONFIG_FUJITSU_ES is not set
CONFIG_HYPERV_NET=m
CONFIG_ISDN=y
CONFIG_ISDN_I4L=m
CONFIG_ISDN_PPP=y
CONFIG_ISDN_PPP_VJ=y
CONFIG_ISDN_MPP=y
CONFIG_IPPP_FILTER=y
# CONFIG_ISDN_PPP_BSDCOMP is not set
CONFIG_ISDN_AUDIO=y
CONFIG_ISDN_TTY_FAX=y

#
# ISDN feature submodules
#
CONFIG_ISDN_DIVERSION=m

#
# ISDN4Linux hardware drivers
#

#
# Passive cards
#
# CONFIG_ISDN_DRV_HISAX is not set
CONFIG_ISDN_CAPI=m
# CONFIG_CAPI_TRACE is not set
CONFIG_ISDN_CAPI_CAPI20=m
CONFIG_ISDN_CAPI_MIDDLEWARE=y
CONFIG_ISDN_CAPI_CAPIDRV=m
# CONFIG_ISDN_CAPI_CAPIDRV_VERBOSE is not set

#
# CAPI hardware drivers
#
CONFIG_CAPI_AVM=y
CONFIG_ISDN_DRV_AVMB1_B1PCI=m
CONFIG_ISDN_DRV_AVMB1_B1PCIV4=y
CONFIG_ISDN_DRV_AVMB1_T1PCI=m
CONFIG_ISDN_DRV_AVMB1_C4=m
# CONFIG_CAPI_EICON is not set
CONFIG_ISDN_DRV_GIGASET=m
CONFIG_GIGASET_CAPI=y
# CONFIG_GIGASET_I4L is not set
# CONFIG_GIGASET_DUMMYLL is not set
CONFIG_GIGASET_BASE=m
CONFIG_GIGASET_M105=m
CONFIG_GIGASET_M101=m
# CONFIG_GIGASET_DEBUG is not set
CONFIG_HYSDN=m
CONFIG_HYSDN_CAPI=y
CONFIG_MISDN=m
CONFIG_MISDN_DSP=m
CONFIG_MISDN_L1OIP=m

#
# mISDN hardware drivers
#
CONFIG_MISDN_HFCPCI=m
CONFIG_MISDN_HFCMULTI=m
CONFIG_MISDN_HFCUSB=m
CONFIG_MISDN_AVMFRITZ=m
CONFIG_MISDN_SPEEDFAX=m
CONFIG_MISDN_INFINEON=m
CONFIG_MISDN_W6692=m
CONFIG_MISDN_NETJET=m
CONFIG_MISDN_IPAC=m
CONFIG_MISDN_ISAR=m
CONFIG_ISDN_HDLC=m
# CONFIG_NVM is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_LEDS=y
CONFIG_INPUT_FF_MEMLESS=m
CONFIG_INPUT_POLLDEV=m
CONFIG_INPUT_SPARSEKMAP=m
# CONFIG_INPUT_MATRIXKMAP is not set

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
# CONFIG_INPUT_MOUSEDEV_PSAUX is not set
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
# CONFIG_INPUT_JOYDEV is not set
CONFIG_INPUT_EVDEV=y
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADP5588 is not set
# CONFIG_KEYBOARD_ADP5589 is not set
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1070 is not set
# CONFIG_KEYBOARD_QT2160 is not set
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_GPIO is not set
# CONFIG_KEYBOARD_GPIO_POLLED is not set
# CONFIG_KEYBOARD_TCA6416 is not set
# CONFIG_KEYBOARD_TCA8418 is not set
# CONFIG_KEYBOARD_MATRIX is not set
# CONFIG_KEYBOARD_LM8323 is not set
# CONFIG_KEYBOARD_LM8333 is not set
# CONFIG_KEYBOARD_MAX7359 is not set
# CONFIG_KEYBOARD_MCS is not set
# CONFIG_KEYBOARD_MPR121 is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_OPENCORES is not set
# CONFIG_KEYBOARD_SAMSUNG is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_TM2_TOUCHKEY is not set
# CONFIG_KEYBOARD_XTKBD is not set
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_BYD=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
CONFIG_MOUSE_PS2_CYPRESS=y
CONFIG_MOUSE_PS2_LIFEBOOK=y
CONFIG_MOUSE_PS2_TRACKPOINT=y
CONFIG_MOUSE_PS2_ELANTECH=y
CONFIG_MOUSE_PS2_SENTELIC=y
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
CONFIG_MOUSE_PS2_FOCALTECH=y
# CONFIG_MOUSE_PS2_VMMOUSE is not set
CONFIG_MOUSE_SERIAL=m
CONFIG_MOUSE_APPLETOUCH=m
CONFIG_MOUSE_BCM5974=m
CONFIG_MOUSE_CYAPA=m
# CONFIG_MOUSE_ELAN_I2C is not set
CONFIG_MOUSE_VSXXXAA=m
# CONFIG_MOUSE_GPIO is not set
CONFIG_MOUSE_SYNAPTICS_I2C=m
CONFIG_MOUSE_SYNAPTICS_USB=m
# CONFIG_INPUT_JOYSTICK is not set
CONFIG_INPUT_TABLET=y
CONFIG_TABLET_USB_ACECAD=m
CONFIG_TABLET_USB_AIPTEK=m
CONFIG_TABLET_USB_GTCO=m
# CONFIG_TABLET_USB_HANWANG is not set
CONFIG_TABLET_USB_KBTAB=m
# CONFIG_TABLET_USB_PEGASUS is not set
# CONFIG_TABLET_SERIAL_WACOM4 is not set
CONFIG_INPUT_TOUCHSCREEN=y
CONFIG_TOUCHSCREEN_PROPERTIES=y
# CONFIG_TOUCHSCREEN_ADS7846 is not set
# CONFIG_TOUCHSCREEN_AD7877 is not set
# CONFIG_TOUCHSCREEN_AD7879 is not set
# CONFIG_TOUCHSCREEN_ATMEL_MXT is not set
# CONFIG_TOUCHSCREEN_AUO_PIXCIR is not set
# CONFIG_TOUCHSCREEN_BU21013 is not set
# CONFIG_TOUCHSCREEN_CY8CTMG110 is not set
# CONFIG_TOUCHSCREEN_CYTTSP_CORE is not set
# CONFIG_TOUCHSCREEN_CYTTSP4_CORE is not set
# CONFIG_TOUCHSCREEN_DYNAPRO is not set
# CONFIG_TOUCHSCREEN_HAMPSHIRE is not set
# CONFIG_TOUCHSCREEN_EETI is not set
# CONFIG_TOUCHSCREEN_EGALAX_SERIAL is not set
# CONFIG_TOUCHSCREEN_FUJITSU is not set
# CONFIG_TOUCHSCREEN_GOODIX is not set
# CONFIG_TOUCHSCREEN_ILI210X is not set
# CONFIG_TOUCHSCREEN_GUNZE is not set
# CONFIG_TOUCHSCREEN_EKTF2127 is not set
# CONFIG_TOUCHSCREEN_ELAN is not set
# CONFIG_TOUCHSCREEN_ELO is not set
CONFIG_TOUCHSCREEN_WACOM_W8001=m
CONFIG_TOUCHSCREEN_WACOM_I2C=m
# CONFIG_TOUCHSCREEN_MAX11801 is not set
# CONFIG_TOUCHSCREEN_MCS5000 is not set
# CONFIG_TOUCHSCREEN_MMS114 is not set
# CONFIG_TOUCHSCREEN_MELFAS_MIP4 is not set
# CONFIG_TOUCHSCREEN_MTOUCH is not set
# CONFIG_TOUCHSCREEN_INEXIO is not set
# CONFIG_TOUCHSCREEN_MK712 is not set
# CONFIG_TOUCHSCREEN_PENMOUNT is not set
# CONFIG_TOUCHSCREEN_EDT_FT5X06 is not set
# CONFIG_TOUCHSCREEN_TOUCHRIGHT is not set
# CONFIG_TOUCHSCREEN_TOUCHWIN is not set
# CONFIG_TOUCHSCREEN_PIXCIR is not set
# CONFIG_TOUCHSCREEN_WDT87XX_I2C is not set
# CONFIG_TOUCHSCREEN_WM97XX is not set
# CONFIG_TOUCHSCREEN_USB_COMPOSITE is not set
# CONFIG_TOUCHSCREEN_TOUCHIT213 is not set
# CONFIG_TOUCHSCREEN_TSC_SERIO is not set
# CONFIG_TOUCHSCREEN_TSC2004 is not set
# CONFIG_TOUCHSCREEN_TSC2005 is not set
# CONFIG_TOUCHSCREEN_TSC2007 is not set
# CONFIG_TOUCHSCREEN_RM_TS is not set
# CONFIG_TOUCHSCREEN_SILEAD is not set
# CONFIG_TOUCHSCREEN_SIS_I2C is not set
# CONFIG_TOUCHSCREEN_ST1232 is not set
# CONFIG_TOUCHSCREEN_SUR40 is not set
# CONFIG_TOUCHSCREEN_SURFACE3_SPI is not set
# CONFIG_TOUCHSCREEN_SX8654 is not set
# CONFIG_TOUCHSCREEN_TPS6507X is not set
# CONFIG_TOUCHSCREEN_ZET6223 is not set
# CONFIG_TOUCHSCREEN_ZFORCE is not set
# CONFIG_TOUCHSCREEN_ROHM_BU21023 is not set
CONFIG_INPUT_MISC=y
# CONFIG_INPUT_AD714X is not set
# CONFIG_INPUT_BMA150 is not set
# CONFIG_INPUT_E3X0_BUTTON is not set
CONFIG_INPUT_PCSPKR=m
# CONFIG_INPUT_MMA8450 is not set
CONFIG_INPUT_APANEL=m
# CONFIG_INPUT_GP2A is not set
# CONFIG_INPUT_GPIO_BEEPER is not set
# CONFIG_INPUT_GPIO_TILT_POLLED is not set
# CONFIG_INPUT_GPIO_DECODER is not set
CONFIG_INPUT_ATLAS_BTNS=m
CONFIG_INPUT_ATI_REMOTE2=m
CONFIG_INPUT_KEYSPAN_REMOTE=m
# CONFIG_INPUT_KXTJ9 is not set
CONFIG_INPUT_POWERMATE=m
CONFIG_INPUT_YEALINK=m
CONFIG_INPUT_CM109=m
CONFIG_INPUT_UINPUT=m
# CONFIG_INPUT_PCF8574 is not set
# CONFIG_INPUT_PWM_BEEPER is not set
# CONFIG_INPUT_GPIO_ROTARY_ENCODER is not set
# CONFIG_INPUT_ADXL34X is not set
# CONFIG_INPUT_IMS_PCU is not set
# CONFIG_INPUT_CMA3000 is not set
CONFIG_INPUT_XEN_KBDDEV_FRONTEND=m
# CONFIG_INPUT_IDEAPAD_SLIDEBAR is not set
# CONFIG_INPUT_DRV260X_HAPTICS is not set
# CONFIG_INPUT_DRV2665_HAPTICS is not set
# CONFIG_INPUT_DRV2667_HAPTICS is not set
# CONFIG_RMI4_CORE is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
# CONFIG_SERIO_CT82C710 is not set
# CONFIG_SERIO_PARKBD is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=m
CONFIG_SERIO_ALTERA_PS2=m
# CONFIG_SERIO_PS2MULT is not set
CONFIG_SERIO_ARC_PS2=m
CONFIG_HYPERV_KEYBOARD=m
# CONFIG_USERIO is not set
# CONFIG_GAMEPORT is not set

#
# Character devices
#
CONFIG_TTY=y
CONFIG_VT=y
CONFIG_CONSOLE_TRANSLATIONS=y
CONFIG_VT_CONSOLE=y
CONFIG_VT_CONSOLE_SLEEP=y
CONFIG_HW_CONSOLE=y
CONFIG_VT_HW_CONSOLE_BINDING=y
CONFIG_UNIX98_PTYS=y
# CONFIG_LEGACY_PTYS is not set
CONFIG_SERIAL_NONSTANDARD=y
# CONFIG_ROCKETPORT is not set
CONFIG_CYCLADES=m
# CONFIG_CYZ_INTR is not set
CONFIG_MOXA_INTELLIO=m
CONFIG_MOXA_SMARTIO=m
CONFIG_SYNCLINK=m
CONFIG_SYNCLINKMP=m
CONFIG_SYNCLINK_GT=m
CONFIG_NOZOMI=m
# CONFIG_ISI is not set
CONFIG_N_HDLC=m
CONFIG_N_GSM=m
# CONFIG_TRACE_SINK is not set
CONFIG_DEVMEM=y
# CONFIG_DEVKMEM is not set

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=y
CONFIG_SERIAL_8250=y
# CONFIG_SERIAL_8250_DEPRECATED_OPTIONS is not set
CONFIG_SERIAL_8250_PNP=y
# CONFIG_SERIAL_8250_FINTEK is not set
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_8250_DMA=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_EXAR=y
CONFIG_SERIAL_8250_NR_UARTS=32
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
CONFIG_SERIAL_8250_MANY_PORTS=y
CONFIG_SERIAL_8250_SHARE_IRQ=y
# CONFIG_SERIAL_8250_DETECT_IRQ is not set
CONFIG_SERIAL_8250_RSA=y
# CONFIG_SERIAL_8250_FSL is not set
CONFIG_SERIAL_8250_DW=y
# CONFIG_SERIAL_8250_RT288X is not set
CONFIG_SERIAL_8250_LPSS=y
CONFIG_SERIAL_8250_MID=y
# CONFIG_SERIAL_8250_MOXA is not set

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_MAX3100 is not set
# CONFIG_SERIAL_MAX310X is not set
# CONFIG_SERIAL_UARTLITE is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
CONFIG_SERIAL_JSM=m
# CONFIG_SERIAL_SCCNXP is not set
# CONFIG_SERIAL_SC16IS7XX is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_IFX6X60 is not set
CONFIG_SERIAL_ARC=m
CONFIG_SERIAL_ARC_NR_PORTS=1
# CONFIG_SERIAL_RP2 is not set
# CONFIG_SERIAL_FSL_LPUART is not set
# CONFIG_SERIAL_DEV_BUS is not set
# CONFIG_TTY_PRINTK is not set
CONFIG_PRINTER=m
# CONFIG_LP_CONSOLE is not set
CONFIG_PPDEV=m
CONFIG_HVC_DRIVER=y
CONFIG_HVC_IRQ=y
CONFIG_HVC_XEN=y
CONFIG_HVC_XEN_FRONTEND=y
CONFIG_VIRTIO_CONSOLE=y
CONFIG_IPMI_HANDLER=m
# CONFIG_IPMI_PANIC_EVENT is not set
CONFIG_IPMI_DEVICE_INTERFACE=m
CONFIG_IPMI_SI=m
# CONFIG_IPMI_SSIF is not set
CONFIG_IPMI_WATCHDOG=m
CONFIG_IPMI_POWEROFF=m
CONFIG_HW_RANDOM=y
CONFIG_HW_RANDOM_TIMERIOMEM=m
CONFIG_HW_RANDOM_INTEL=m
CONFIG_HW_RANDOM_AMD=m
CONFIG_HW_RANDOM_VIA=m
CONFIG_HW_RANDOM_VIRTIO=y
CONFIG_HW_RANDOM_TPM=m
CONFIG_NVRAM=y
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
# CONFIG_MWAVE is not set
CONFIG_RAW_DRIVER=y
CONFIG_MAX_RAW_DEVS=8192
CONFIG_HPET=y
CONFIG_HPET_MMAP=y
# CONFIG_HPET_MMAP_DEFAULT is not set
CONFIG_HANGCHECK_TIMER=m
CONFIG_UV_MMTIMER=m
CONFIG_TCG_TPM=y
CONFIG_TCG_TIS_CORE=y
CONFIG_TCG_TIS=y
# CONFIG_TCG_TIS_SPI is not set
# CONFIG_TCG_TIS_I2C_ATMEL is not set
# CONFIG_TCG_TIS_I2C_INFINEON is not set
# CONFIG_TCG_TIS_I2C_NUVOTON is not set
CONFIG_TCG_NSC=m
CONFIG_TCG_ATMEL=m
CONFIG_TCG_INFINEON=m
# CONFIG_TCG_XEN is not set
# CONFIG_TCG_CRB is not set
# CONFIG_TCG_VTPM_PROXY is not set
# CONFIG_TCG_TIS_ST33ZP24_I2C is not set
# CONFIG_TCG_TIS_ST33ZP24_SPI is not set
CONFIG_TELCLOCK=m
CONFIG_DEVPORT=y
# CONFIG_XILLYBUS is not set

#
# I2C support
#
CONFIG_I2C=y
CONFIG_ACPI_I2C_OPREGION=y
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_COMPAT=y
CONFIG_I2C_CHARDEV=m
CONFIG_I2C_MUX=m

#
# Multiplexer I2C Chip support
#
# CONFIG_I2C_MUX_GPIO is not set
# CONFIG_I2C_MUX_PCA9541 is not set
# CONFIG_I2C_MUX_PCA954x is not set
# CONFIG_I2C_MUX_PINCTRL is not set
# CONFIG_I2C_MUX_REG is not set
# CONFIG_I2C_MUX_MLXCPLD is not set
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_SMBUS=y
CONFIG_I2C_ALGOBIT=y
CONFIG_I2C_ALGOPCA=m

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
# CONFIG_I2C_ALI1535 is not set
# CONFIG_I2C_ALI1563 is not set
# CONFIG_I2C_ALI15X3 is not set
CONFIG_I2C_AMD756=m
CONFIG_I2C_AMD756_S4882=m
CONFIG_I2C_AMD8111=m
CONFIG_I2C_I801=y
CONFIG_I2C_ISCH=m
CONFIG_I2C_ISMT=m
CONFIG_I2C_PIIX4=m
CONFIG_I2C_NFORCE2=m
CONFIG_I2C_NFORCE2_S4985=m
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
CONFIG_I2C_SIS96X=m
CONFIG_I2C_VIA=m
CONFIG_I2C_VIAPRO=m

#
# ACPI drivers
#
CONFIG_I2C_SCMI=m

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
# CONFIG_I2C_CBUS_GPIO is not set
CONFIG_I2C_DESIGNWARE_CORE=m
CONFIG_I2C_DESIGNWARE_PLATFORM=m
CONFIG_I2C_DESIGNWARE_PCI=m
# CONFIG_I2C_DESIGNWARE_BAYTRAIL is not set
# CONFIG_I2C_EMEV2 is not set
# CONFIG_I2C_GPIO is not set
# CONFIG_I2C_OCORES is not set
CONFIG_I2C_PCA_PLATFORM=m
# CONFIG_I2C_PXA_PCI is not set
CONFIG_I2C_SIMTEC=m
# CONFIG_I2C_XILINX is not set

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_DIOLAN_U2C=m
CONFIG_I2C_PARPORT=m
CONFIG_I2C_PARPORT_LIGHT=m
# CONFIG_I2C_ROBOTFUZZ_OSIF is not set
# CONFIG_I2C_TAOS_EVM is not set
CONFIG_I2C_TINY_USB=m
CONFIG_I2C_VIPERBOARD=m

#
# Other I2C/SMBus bus drivers
#
# CONFIG_I2C_MLXCPLD is not set
CONFIG_I2C_STUB=m
# CONFIG_I2C_SLAVE is not set
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
CONFIG_SPI=y
# CONFIG_SPI_DEBUG is not set
CONFIG_SPI_MASTER=y

#
# SPI Master Controller Drivers
#
# CONFIG_SPI_ALTERA is not set
# CONFIG_SPI_AXI_SPI_ENGINE is not set
# CONFIG_SPI_BITBANG is not set
# CONFIG_SPI_BUTTERFLY is not set
# CONFIG_SPI_CADENCE is not set
CONFIG_SPI_DESIGNWARE=m
# CONFIG_SPI_DW_PCI is not set
# CONFIG_SPI_DW_MMIO is not set
# CONFIG_SPI_GPIO is not set
# CONFIG_SPI_LM70_LLP is not set
# CONFIG_SPI_OC_TINY is not set
CONFIG_SPI_PXA2XX=m
CONFIG_SPI_PXA2XX_PCI=m
# CONFIG_SPI_ROCKCHIP is not set
# CONFIG_SPI_SC18IS602 is not set
# CONFIG_SPI_XCOMM is not set
# CONFIG_SPI_XILINX is not set
# CONFIG_SPI_ZYNQMP_GQSPI is not set

#
# SPI Protocol Masters
#
# CONFIG_SPI_SPIDEV is not set
# CONFIG_SPI_LOOPBACK_TEST is not set
# CONFIG_SPI_TLE62X0 is not set
# CONFIG_SPMI is not set
# CONFIG_HSI is not set

#
# PPS support
#
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set

#
# PPS clients support
#
# CONFIG_PPS_CLIENT_KTIMER is not set
CONFIG_PPS_CLIENT_LDISC=m
CONFIG_PPS_CLIENT_PARPORT=m
CONFIG_PPS_CLIENT_GPIO=m

#
# PPS generators support
#

#
# PTP clock support
#
CONFIG_PTP_1588_CLOCK=y
CONFIG_DP83640_PHY=m
CONFIG_PTP_1588_CLOCK_KVM=y
CONFIG_PINCTRL=y

#
# Pin controllers
#
CONFIG_PINMUX=y
CONFIG_PINCONF=y
CONFIG_GENERIC_PINCONF=y
# CONFIG_DEBUG_PINCTRL is not set
# CONFIG_PINCTRL_AMD is not set
# CONFIG_PINCTRL_SX150X is not set
CONFIG_PINCTRL_BAYTRAIL=y
# CONFIG_PINCTRL_CHERRYVIEW is not set
# CONFIG_PINCTRL_BROXTON is not set
# CONFIG_PINCTRL_GEMINILAKE is not set
# CONFIG_PINCTRL_SUNRISEPOINT is not set
CONFIG_GPIOLIB=y
CONFIG_GPIO_ACPI=y
CONFIG_GPIOLIB_IRQCHIP=y
# CONFIG_DEBUG_GPIO is not set
CONFIG_GPIO_SYSFS=y

#
# Memory mapped GPIO drivers
#
# CONFIG_GPIO_AMDPT is not set
# CONFIG_GPIO_DWAPB is not set
# CONFIG_GPIO_EXAR is not set
# CONFIG_GPIO_GENERIC_PLATFORM is not set
# CONFIG_GPIO_ICH is not set
CONFIG_GPIO_LYNXPOINT=m
CONFIG_GPIO_MOCKUP=y
# CONFIG_GPIO_VX855 is not set

#
# Port-mapped I/O GPIO drivers
#
# CONFIG_GPIO_F7188X is not set
# CONFIG_GPIO_IT87 is not set
# CONFIG_GPIO_SCH is not set
# CONFIG_GPIO_SCH311X is not set

#
# I2C GPIO expanders
#
# CONFIG_GPIO_ADP5588 is not set
# CONFIG_GPIO_MAX7300 is not set
# CONFIG_GPIO_MAX732X is not set
# CONFIG_GPIO_PCA953X is not set
# CONFIG_GPIO_PCF857X is not set
# CONFIG_GPIO_SX150X is not set
# CONFIG_GPIO_TPIC2810 is not set

#
# MFD GPIO expanders
#

#
# PCI GPIO expanders
#
# CONFIG_GPIO_AMD8111 is not set
# CONFIG_GPIO_ML_IOH is not set
# CONFIG_GPIO_PCI_IDIO_16 is not set
# CONFIG_GPIO_RDC321X is not set

#
# SPI GPIO expanders
#
# CONFIG_GPIO_MAX7301 is not set
# CONFIG_GPIO_MC33880 is not set
# CONFIG_GPIO_PISOSR is not set

#
# SPI or I2C GPIO expanders
#

#
# USB GPIO expanders
#
# CONFIG_GPIO_VIPERBOARD is not set
# CONFIG_W1 is not set
# CONFIG_POWER_AVS is not set
CONFIG_POWER_RESET=y
# CONFIG_POWER_RESET_RESTART is not set
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
# CONFIG_PDA_POWER is not set
# CONFIG_TEST_POWER is not set
# CONFIG_BATTERY_DS2780 is not set
# CONFIG_BATTERY_DS2781 is not set
# CONFIG_BATTERY_DS2782 is not set
# CONFIG_BATTERY_SBS is not set
# CONFIG_CHARGER_SBS is not set
# CONFIG_BATTERY_BQ27XXX is not set
# CONFIG_BATTERY_MAX17040 is not set
# CONFIG_BATTERY_MAX17042 is not set
# CONFIG_CHARGER_ISP1704 is not set
# CONFIG_CHARGER_MAX8903 is not set
# CONFIG_CHARGER_LP8727 is not set
# CONFIG_CHARGER_GPIO is not set
# CONFIG_CHARGER_BQ2415X is not set
# CONFIG_CHARGER_BQ24190 is not set
# CONFIG_CHARGER_BQ24257 is not set
# CONFIG_CHARGER_BQ24735 is not set
# CONFIG_CHARGER_BQ25890 is not set
CONFIG_CHARGER_SMB347=m
# CONFIG_BATTERY_GAUGE_LTC2941 is not set
# CONFIG_CHARGER_RT9455 is not set
CONFIG_HWMON=y
CONFIG_HWMON_VID=m
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
CONFIG_SENSORS_ABITUGURU=m
CONFIG_SENSORS_ABITUGURU3=m
# CONFIG_SENSORS_AD7314 is not set
CONFIG_SENSORS_AD7414=m
CONFIG_SENSORS_AD7418=m
CONFIG_SENSORS_ADM1021=m
CONFIG_SENSORS_ADM1025=m
CONFIG_SENSORS_ADM1026=m
CONFIG_SENSORS_ADM1029=m
CONFIG_SENSORS_ADM1031=m
CONFIG_SENSORS_ADM9240=m
CONFIG_SENSORS_ADT7X10=m
# CONFIG_SENSORS_ADT7310 is not set
CONFIG_SENSORS_ADT7410=m
CONFIG_SENSORS_ADT7411=m
CONFIG_SENSORS_ADT7462=m
CONFIG_SENSORS_ADT7470=m
CONFIG_SENSORS_ADT7475=m
CONFIG_SENSORS_ASC7621=m
CONFIG_SENSORS_K8TEMP=m
CONFIG_SENSORS_K10TEMP=m
CONFIG_SENSORS_FAM15H_POWER=m
CONFIG_SENSORS_APPLESMC=m
CONFIG_SENSORS_ASB100=m
CONFIG_SENSORS_ATXP1=m
CONFIG_SENSORS_DS620=m
CONFIG_SENSORS_DS1621=m
CONFIG_SENSORS_DELL_SMM=m
CONFIG_SENSORS_I5K_AMB=m
CONFIG_SENSORS_F71805F=m
CONFIG_SENSORS_F71882FG=m
CONFIG_SENSORS_F75375S=m
CONFIG_SENSORS_FSCHMD=m
# CONFIG_SENSORS_FTSTEUTATES is not set
CONFIG_SENSORS_GL518SM=m
CONFIG_SENSORS_GL520SM=m
CONFIG_SENSORS_G760A=m
# CONFIG_SENSORS_G762 is not set
# CONFIG_SENSORS_GPIO_FAN is not set
# CONFIG_SENSORS_HIH6130 is not set
CONFIG_SENSORS_IBMAEM=m
CONFIG_SENSORS_IBMPEX=m
# CONFIG_SENSORS_I5500 is not set
CONFIG_SENSORS_CORETEMP=m
CONFIG_SENSORS_IT87=m
# CONFIG_SENSORS_JC42 is not set
# CONFIG_SENSORS_POWR1220 is not set
CONFIG_SENSORS_LINEAGE=m
# CONFIG_SENSORS_LTC2945 is not set
# CONFIG_SENSORS_LTC2990 is not set
CONFIG_SENSORS_LTC4151=m
CONFIG_SENSORS_LTC4215=m
# CONFIG_SENSORS_LTC4222 is not set
CONFIG_SENSORS_LTC4245=m
# CONFIG_SENSORS_LTC4260 is not set
CONFIG_SENSORS_LTC4261=m
# CONFIG_SENSORS_MAX1111 is not set
CONFIG_SENSORS_MAX16065=m
CONFIG_SENSORS_MAX1619=m
CONFIG_SENSORS_MAX1668=m
CONFIG_SENSORS_MAX197=m
# CONFIG_SENSORS_MAX31722 is not set
CONFIG_SENSORS_MAX6639=m
CONFIG_SENSORS_MAX6642=m
CONFIG_SENSORS_MAX6650=m
CONFIG_SENSORS_MAX6697=m
# CONFIG_SENSORS_MAX31790 is not set
CONFIG_SENSORS_MCP3021=m
# CONFIG_SENSORS_TC654 is not set
# CONFIG_SENSORS_ADCXX is not set
CONFIG_SENSORS_LM63=m
# CONFIG_SENSORS_LM70 is not set
CONFIG_SENSORS_LM73=m
CONFIG_SENSORS_LM75=m
CONFIG_SENSORS_LM77=m
CONFIG_SENSORS_LM78=m
CONFIG_SENSORS_LM80=m
CONFIG_SENSORS_LM83=m
CONFIG_SENSORS_LM85=m
CONFIG_SENSORS_LM87=m
CONFIG_SENSORS_LM90=m
CONFIG_SENSORS_LM92=m
CONFIG_SENSORS_LM93=m
CONFIG_SENSORS_LM95234=m
CONFIG_SENSORS_LM95241=m
CONFIG_SENSORS_LM95245=m
CONFIG_SENSORS_PC87360=m
CONFIG_SENSORS_PC87427=m
CONFIG_SENSORS_NTC_THERMISTOR=m
# CONFIG_SENSORS_NCT6683 is not set
CONFIG_SENSORS_NCT6775=m
# CONFIG_SENSORS_NCT7802 is not set
# CONFIG_SENSORS_NCT7904 is not set
CONFIG_SENSORS_PCF8591=m
CONFIG_PMBUS=m
CONFIG_SENSORS_PMBUS=m
CONFIG_SENSORS_ADM1275=m
CONFIG_SENSORS_LM25066=m
CONFIG_SENSORS_LTC2978=m
# CONFIG_SENSORS_LTC3815 is not set
CONFIG_SENSORS_MAX16064=m
# CONFIG_SENSORS_MAX20751 is not set
CONFIG_SENSORS_MAX34440=m
CONFIG_SENSORS_MAX8688=m
# CONFIG_SENSORS_TPS40422 is not set
CONFIG_SENSORS_UCD9000=m
CONFIG_SENSORS_UCD9200=m
CONFIG_SENSORS_ZL6100=m
# CONFIG_SENSORS_SHT15 is not set
CONFIG_SENSORS_SHT21=m
# CONFIG_SENSORS_SHT3x is not set
# CONFIG_SENSORS_SHTC1 is not set
CONFIG_SENSORS_SIS5595=m
CONFIG_SENSORS_DME1737=m
CONFIG_SENSORS_EMC1403=m
# CONFIG_SENSORS_EMC2103 is not set
CONFIG_SENSORS_EMC6W201=m
CONFIG_SENSORS_SMSC47M1=m
CONFIG_SENSORS_SMSC47M192=m
CONFIG_SENSORS_SMSC47B397=m
CONFIG_SENSORS_SCH56XX_COMMON=m
CONFIG_SENSORS_SCH5627=m
CONFIG_SENSORS_SCH5636=m
# CONFIG_SENSORS_STTS751 is not set
# CONFIG_SENSORS_SMM665 is not set
# CONFIG_SENSORS_ADC128D818 is not set
CONFIG_SENSORS_ADS1015=m
CONFIG_SENSORS_ADS7828=m
# CONFIG_SENSORS_ADS7871 is not set
CONFIG_SENSORS_AMC6821=m
CONFIG_SENSORS_INA209=m
CONFIG_SENSORS_INA2XX=m
# CONFIG_SENSORS_INA3221 is not set
# CONFIG_SENSORS_TC74 is not set
CONFIG_SENSORS_THMC50=m
CONFIG_SENSORS_TMP102=m
# CONFIG_SENSORS_TMP103 is not set
# CONFIG_SENSORS_TMP108 is not set
CONFIG_SENSORS_TMP401=m
CONFIG_SENSORS_TMP421=m
CONFIG_SENSORS_VIA_CPUTEMP=m
CONFIG_SENSORS_VIA686A=m
CONFIG_SENSORS_VT1211=m
CONFIG_SENSORS_VT8231=m
CONFIG_SENSORS_W83781D=m
CONFIG_SENSORS_W83791D=m
CONFIG_SENSORS_W83792D=m
CONFIG_SENSORS_W83793=m
CONFIG_SENSORS_W83795=m
# CONFIG_SENSORS_W83795_FANCTRL is not set
CONFIG_SENSORS_W83L785TS=m
CONFIG_SENSORS_W83L786NG=m
CONFIG_SENSORS_W83627HF=m
CONFIG_SENSORS_W83627EHF=m
# CONFIG_SENSORS_XGENE is not set

#
# ACPI drivers
#
CONFIG_SENSORS_ACPI_POWER=m
CONFIG_SENSORS_ATK0110=m
CONFIG_THERMAL=y
CONFIG_THERMAL_HWMON=y
CONFIG_THERMAL_WRITABLE_TRIPS=y
CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=y
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_DEFAULT_GOV_POWER_ALLOCATOR is not set
CONFIG_THERMAL_GOV_FAIR_SHARE=y
CONFIG_THERMAL_GOV_STEP_WISE=y
CONFIG_THERMAL_GOV_BANG_BANG=y
CONFIG_THERMAL_GOV_USER_SPACE=y
# CONFIG_THERMAL_GOV_POWER_ALLOCATOR is not set
# CONFIG_THERMAL_EMULATION is not set
CONFIG_INTEL_POWERCLAMP=m
CONFIG_X86_PKG_TEMP_THERMAL=m
# CONFIG_INTEL_SOC_DTS_THERMAL is not set

#
# ACPI INT340X thermal drivers
#
# CONFIG_INT340X_THERMAL is not set
CONFIG_INTEL_PCH_THERMAL=m
CONFIG_WATCHDOG=y
CONFIG_WATCHDOG_CORE=y
# CONFIG_WATCHDOG_NOWAYOUT is not set
# CONFIG_WATCHDOG_SYSFS is not set

#
# Watchdog Device Drivers
#
CONFIG_SOFT_WATCHDOG=m
# CONFIG_WDAT_WDT is not set
# CONFIG_XILINX_WATCHDOG is not set
# CONFIG_ZIIRAVE_WATCHDOG is not set
# CONFIG_CADENCE_WATCHDOG is not set
# CONFIG_DW_WATCHDOG is not set
# CONFIG_MAX63XX_WATCHDOG is not set
# CONFIG_ACQUIRE_WDT is not set
# CONFIG_ADVANTECH_WDT is not set
CONFIG_ALIM1535_WDT=m
CONFIG_ALIM7101_WDT=m
CONFIG_F71808E_WDT=m
CONFIG_SP5100_TCO=m
CONFIG_SBC_FITPC2_WATCHDOG=m
# CONFIG_EUROTECH_WDT is not set
CONFIG_IB700_WDT=m
CONFIG_IBMASR=m
# CONFIG_WAFER_WDT is not set
CONFIG_I6300ESB_WDT=y
CONFIG_IE6XX_WDT=m
CONFIG_ITCO_WDT=y
CONFIG_ITCO_VENDOR_SUPPORT=y
CONFIG_IT8712F_WDT=m
CONFIG_IT87_WDT=m
CONFIG_HP_WATCHDOG=m
CONFIG_HPWDT_NMI_DECODING=y
# CONFIG_SC1200_WDT is not set
# CONFIG_PC87413_WDT is not set
CONFIG_NV_TCO=m
# CONFIG_60XX_WDT is not set
# CONFIG_CPU5_WDT is not set
CONFIG_SMSC_SCH311X_WDT=m
# CONFIG_SMSC37B787_WDT is not set
CONFIG_VIA_WDT=m
CONFIG_W83627HF_WDT=m
CONFIG_W83877F_WDT=m
CONFIG_W83977F_WDT=m
CONFIG_MACHZ_WDT=m
# CONFIG_SBC_EPX_C3_WATCHDOG is not set
# CONFIG_INTEL_MEI_WDT is not set
# CONFIG_NI903X_WDT is not set
# CONFIG_NIC7018_WDT is not set
# CONFIG_MEN_A21_WDT is not set
CONFIG_XEN_WDT=m

#
# PCI-based Watchdog Cards
#
CONFIG_PCIPCWATCHDOG=m
CONFIG_WDTPCI=m

#
# USB-based Watchdog Cards
#
CONFIG_USBPCWATCHDOG=m

#
# Watchdog Pretimeout Governors
#
# CONFIG_WATCHDOG_PRETIMEOUT_GOV is not set
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
CONFIG_SSB=m
CONFIG_SSB_SPROM=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
CONFIG_SSB_PCIHOST=y
# CONFIG_SSB_B43_PCI_BRIDGE is not set
CONFIG_SSB_SDIOHOST_POSSIBLE=y
CONFIG_SSB_SDIOHOST=y
# CONFIG_SSB_SILENT is not set
# CONFIG_SSB_DEBUG is not set
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
CONFIG_SSB_DRIVER_PCICORE=y
# CONFIG_SSB_DRIVER_GPIO is not set
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
CONFIG_BCMA=m
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
CONFIG_BCMA_HOST_PCI=y
# CONFIG_BCMA_HOST_SOC is not set
CONFIG_BCMA_DRIVER_PCI=y
CONFIG_BCMA_DRIVER_GMAC_CMN=y
# CONFIG_BCMA_DRIVER_GPIO is not set
# CONFIG_BCMA_DEBUG is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
# CONFIG_MFD_AS3711 is not set
# CONFIG_PMIC_ADP5520 is not set
# CONFIG_MFD_AAT2870_CORE is not set
# CONFIG_MFD_BCM590XX is not set
# CONFIG_MFD_AXP20X_I2C is not set
# CONFIG_MFD_CROS_EC is not set
# CONFIG_PMIC_DA903X is not set
# CONFIG_MFD_DA9052_SPI is not set
# CONFIG_MFD_DA9052_I2C is not set
# CONFIG_MFD_DA9055 is not set
# CONFIG_MFD_DA9062 is not set
# CONFIG_MFD_DA9063 is not set
# CONFIG_MFD_DA9150 is not set
# CONFIG_MFD_DLN2 is not set
# CONFIG_MFD_MC13XXX_SPI is not set
# CONFIG_MFD_MC13XXX_I2C is not set
# CONFIG_HTC_PASIC3 is not set
# CONFIG_HTC_I2CPLD is not set
# CONFIG_MFD_INTEL_QUARK_I2C_GPIO is not set
CONFIG_LPC_ICH=y
CONFIG_LPC_SCH=m
# CONFIG_INTEL_SOC_PMIC is not set
# CONFIG_MFD_INTEL_LPSS_ACPI is not set
# CONFIG_MFD_INTEL_LPSS_PCI is not set
# CONFIG_MFD_JANZ_CMODIO is not set
# CONFIG_MFD_KEMPLD is not set
# CONFIG_MFD_88PM800 is not set
# CONFIG_MFD_88PM805 is not set
# CONFIG_MFD_88PM860X is not set
# CONFIG_MFD_MAX14577 is not set
# CONFIG_MFD_MAX77693 is not set
# CONFIG_MFD_MAX77843 is not set
# CONFIG_MFD_MAX8907 is not set
# CONFIG_MFD_MAX8925 is not set
# CONFIG_MFD_MAX8997 is not set
# CONFIG_MFD_MAX8998 is not set
# CONFIG_MFD_MT6397 is not set
# CONFIG_MFD_MENF21BMC is not set
# CONFIG_EZX_PCAP is not set
CONFIG_MFD_VIPERBOARD=m
# CONFIG_MFD_RETU is not set
# CONFIG_MFD_PCF50633 is not set
# CONFIG_UCB1400_CORE is not set
# CONFIG_MFD_RDC321X is not set
CONFIG_MFD_RTSX_PCI=m
# CONFIG_MFD_RT5033 is not set
# CONFIG_MFD_RTSX_USB is not set
# CONFIG_MFD_RC5T583 is not set
# CONFIG_MFD_SEC_CORE is not set
# CONFIG_MFD_SI476X_CORE is not set
CONFIG_MFD_SM501=m
# CONFIG_MFD_SM501_GPIO is not set
# CONFIG_MFD_SKY81452 is not set
# CONFIG_MFD_SMSC is not set
# CONFIG_ABX500_CORE is not set
# CONFIG_MFD_SYSCON is not set
# CONFIG_MFD_TI_AM335X_TSCADC is not set
# CONFIG_MFD_LP3943 is not set
# CONFIG_MFD_LP8788 is not set
# CONFIG_MFD_PALMAS is not set
# CONFIG_TPS6105X is not set
# CONFIG_TPS65010 is not set
# CONFIG_TPS6507X is not set
# CONFIG_MFD_TPS65086 is not set
# CONFIG_MFD_TPS65090 is not set
# CONFIG_MFD_TPS65217 is not set
# CONFIG_MFD_TI_LP873X is not set
# CONFIG_MFD_TPS65218 is not set
# CONFIG_MFD_TPS6586X is not set
# CONFIG_MFD_TPS65910 is not set
# CONFIG_MFD_TPS65912_I2C is not set
# CONFIG_MFD_TPS65912_SPI is not set
# CONFIG_MFD_TPS80031 is not set
# CONFIG_TWL4030_CORE is not set
# CONFIG_TWL6040_CORE is not set
# CONFIG_MFD_WL1273_CORE is not set
# CONFIG_MFD_LM3533 is not set
# CONFIG_MFD_TMIO is not set
CONFIG_MFD_VX855=m
# CONFIG_MFD_ARIZONA_I2C is not set
# CONFIG_MFD_ARIZONA_SPI is not set
# CONFIG_MFD_WM8400 is not set
# CONFIG_MFD_WM831X_I2C is not set
# CONFIG_MFD_WM831X_SPI is not set
# CONFIG_MFD_WM8350_I2C is not set
# CONFIG_MFD_WM8994 is not set
# CONFIG_REGULATOR is not set
CONFIG_MEDIA_SUPPORT=m

#
# Multimedia core support
#
CONFIG_MEDIA_CAMERA_SUPPORT=y
CONFIG_MEDIA_ANALOG_TV_SUPPORT=y
CONFIG_MEDIA_DIGITAL_TV_SUPPORT=y
CONFIG_MEDIA_RADIO_SUPPORT=y
# CONFIG_MEDIA_SDR_SUPPORT is not set
CONFIG_MEDIA_RC_SUPPORT=y
# CONFIG_MEDIA_CEC_SUPPORT is not set
# CONFIG_MEDIA_CONTROLLER is not set
CONFIG_VIDEO_DEV=m
CONFIG_VIDEO_V4L2=m
# CONFIG_VIDEO_ADV_DEBUG is not set
# CONFIG_VIDEO_FIXED_MINOR_RANGES is not set
CONFIG_VIDEO_TUNER=m
CONFIG_VIDEOBUF_GEN=m
CONFIG_VIDEOBUF_DMA_SG=m
CONFIG_VIDEOBUF_VMALLOC=m
CONFIG_VIDEOBUF_DVB=m
CONFIG_VIDEOBUF2_CORE=m
CONFIG_VIDEOBUF2_MEMOPS=m
CONFIG_VIDEOBUF2_VMALLOC=m
CONFIG_VIDEOBUF2_DMA_SG=m
CONFIG_VIDEOBUF2_DVB=m
CONFIG_DVB_CORE=m
CONFIG_DVB_NET=y
CONFIG_TTPCI_EEPROM=m
CONFIG_DVB_MAX_ADAPTERS=8
CONFIG_DVB_DYNAMIC_MINORS=y
# CONFIG_DVB_DEMUX_SECTION_LOSS_LOG is not set

#
# Media drivers
#
CONFIG_RC_CORE=m
CONFIG_RC_MAP=m
CONFIG_RC_DECODERS=y
CONFIG_LIRC=m
CONFIG_IR_LIRC_CODEC=m
CONFIG_IR_NEC_DECODER=m
CONFIG_IR_RC5_DECODER=m
CONFIG_IR_RC6_DECODER=m
CONFIG_IR_JVC_DECODER=m
CONFIG_IR_SONY_DECODER=m
CONFIG_IR_SANYO_DECODER=m
CONFIG_IR_SHARP_DECODER=m
CONFIG_IR_MCE_KBD_DECODER=m
CONFIG_IR_XMP_DECODER=m
CONFIG_RC_DEVICES=y
CONFIG_RC_ATI_REMOTE=m
CONFIG_IR_ENE=m
# CONFIG_IR_HIX5HD2 is not set
CONFIG_IR_IMON=m
CONFIG_IR_MCEUSB=m
CONFIG_IR_ITE_CIR=m
CONFIG_IR_FINTEK=m
CONFIG_IR_NUVOTON=m
CONFIG_IR_REDRAT3=m
# CONFIG_IR_SPI is not set
CONFIG_IR_STREAMZAP=m
CONFIG_IR_WINBOND_CIR=m
# CONFIG_IR_IGORPLUGUSB is not set
CONFIG_IR_IGUANA=m
CONFIG_IR_TTUSBIR=m
# CONFIG_RC_LOOPBACK is not set
CONFIG_IR_GPIO_CIR=m
# CONFIG_IR_SERIAL is not set
CONFIG_MEDIA_USB_SUPPORT=y

#
# Webcam devices
#
CONFIG_USB_VIDEO_CLASS=m
CONFIG_USB_VIDEO_CLASS_INPUT_EVDEV=y
CONFIG_USB_GSPCA=m
CONFIG_USB_M5602=m
CONFIG_USB_STV06XX=m
CONFIG_USB_GL860=m
CONFIG_USB_GSPCA_BENQ=m
CONFIG_USB_GSPCA_CONEX=m
CONFIG_USB_GSPCA_CPIA1=m
# CONFIG_USB_GSPCA_DTCS033 is not set
CONFIG_USB_GSPCA_ETOMS=m
CONFIG_USB_GSPCA_FINEPIX=m
CONFIG_USB_GSPCA_JEILINJ=m
CONFIG_USB_GSPCA_JL2005BCD=m
# CONFIG_USB_GSPCA_KINECT is not set
CONFIG_USB_GSPCA_KONICA=m
CONFIG_USB_GSPCA_MARS=m
CONFIG_USB_GSPCA_MR97310A=m
CONFIG_USB_GSPCA_NW80X=m
CONFIG_USB_GSPCA_OV519=m
CONFIG_USB_GSPCA_OV534=m
CONFIG_USB_GSPCA_OV534_9=m
CONFIG_USB_GSPCA_PAC207=m
CONFIG_USB_GSPCA_PAC7302=m
CONFIG_USB_GSPCA_PAC7311=m
CONFIG_USB_GSPCA_SE401=m
CONFIG_USB_GSPCA_SN9C2028=m
CONFIG_USB_GSPCA_SN9C20X=m
CONFIG_USB_GSPCA_SONIXB=m
CONFIG_USB_GSPCA_SONIXJ=m
CONFIG_USB_GSPCA_SPCA500=m
CONFIG_USB_GSPCA_SPCA501=m
CONFIG_USB_GSPCA_SPCA505=m
CONFIG_USB_GSPCA_SPCA506=m
CONFIG_USB_GSPCA_SPCA508=m
CONFIG_USB_GSPCA_SPCA561=m
CONFIG_USB_GSPCA_SPCA1528=m
CONFIG_USB_GSPCA_SQ905=m
CONFIG_USB_GSPCA_SQ905C=m
CONFIG_USB_GSPCA_SQ930X=m
CONFIG_USB_GSPCA_STK014=m
# CONFIG_USB_GSPCA_STK1135 is not set
CONFIG_USB_GSPCA_STV0680=m
CONFIG_USB_GSPCA_SUNPLUS=m
CONFIG_USB_GSPCA_T613=m
CONFIG_USB_GSPCA_TOPRO=m
# CONFIG_USB_GSPCA_TOUPTEK is not set
CONFIG_USB_GSPCA_TV8532=m
CONFIG_USB_GSPCA_VC032X=m
CONFIG_USB_GSPCA_VICAM=m
CONFIG_USB_GSPCA_XIRLINK_CIT=m
CONFIG_USB_GSPCA_ZC3XX=m
CONFIG_USB_PWC=m
# CONFIG_USB_PWC_DEBUG is not set
CONFIG_USB_PWC_INPUT_EVDEV=y
# CONFIG_VIDEO_CPIA2 is not set
CONFIG_USB_ZR364XX=m
CONFIG_USB_STKWEBCAM=m
CONFIG_USB_S2255=m
# CONFIG_VIDEO_USBTV is not set

#
# Analog TV USB devices
#
CONFIG_VIDEO_PVRUSB2=m
CONFIG_VIDEO_PVRUSB2_SYSFS=y
CONFIG_VIDEO_PVRUSB2_DVB=y
# CONFIG_VIDEO_PVRUSB2_DEBUGIFC is not set
CONFIG_VIDEO_HDPVR=m
CONFIG_VIDEO_USBVISION=m
# CONFIG_VIDEO_STK1160_COMMON is not set
# CONFIG_VIDEO_GO7007 is not set

#
# Analog/digital TV USB devices
#
CONFIG_VIDEO_AU0828=m
CONFIG_VIDEO_AU0828_V4L2=y
# CONFIG_VIDEO_AU0828_RC is not set
CONFIG_VIDEO_CX231XX=m
CONFIG_VIDEO_CX231XX_RC=y
CONFIG_VIDEO_CX231XX_ALSA=m
CONFIG_VIDEO_CX231XX_DVB=m
CONFIG_VIDEO_TM6000=m
CONFIG_VIDEO_TM6000_ALSA=m
CONFIG_VIDEO_TM6000_DVB=m

#
# Digital TV USB devices
#
CONFIG_DVB_USB=m
# CONFIG_DVB_USB_DEBUG is not set
CONFIG_DVB_USB_DIB3000MC=m
CONFIG_DVB_USB_A800=m
CONFIG_DVB_USB_DIBUSB_MB=m
# CONFIG_DVB_USB_DIBUSB_MB_FAULTY is not set
CONFIG_DVB_USB_DIBUSB_MC=m
CONFIG_DVB_USB_DIB0700=m
CONFIG_DVB_USB_UMT_010=m
CONFIG_DVB_USB_CXUSB=m
CONFIG_DVB_USB_M920X=m
CONFIG_DVB_USB_DIGITV=m
CONFIG_DVB_USB_VP7045=m
CONFIG_DVB_USB_VP702X=m
CONFIG_DVB_USB_GP8PSK=m
CONFIG_DVB_USB_NOVA_T_USB2=m
CONFIG_DVB_USB_TTUSB2=m
CONFIG_DVB_USB_DTT200U=m
CONFIG_DVB_USB_OPERA1=m
CONFIG_DVB_USB_AF9005=m
CONFIG_DVB_USB_AF9005_REMOTE=m
CONFIG_DVB_USB_PCTV452E=m
CONFIG_DVB_USB_DW2102=m
CONFIG_DVB_USB_CINERGY_T2=m
CONFIG_DVB_USB_DTV5100=m
CONFIG_DVB_USB_FRIIO=m
CONFIG_DVB_USB_AZ6027=m
CONFIG_DVB_USB_TECHNISAT_USB2=m
CONFIG_DVB_USB_V2=m
CONFIG_DVB_USB_AF9015=m
CONFIG_DVB_USB_AF9035=m
CONFIG_DVB_USB_ANYSEE=m
CONFIG_DVB_USB_AU6610=m
CONFIG_DVB_USB_AZ6007=m
CONFIG_DVB_USB_CE6230=m
CONFIG_DVB_USB_EC168=m
CONFIG_DVB_USB_GL861=m
CONFIG_DVB_USB_LME2510=m
CONFIG_DVB_USB_MXL111SF=m
CONFIG_DVB_USB_RTL28XXU=m
# CONFIG_DVB_USB_DVBSKY is not set
# CONFIG_DVB_USB_ZD1301 is not set
CONFIG_DVB_TTUSB_BUDGET=m
CONFIG_DVB_TTUSB_DEC=m
CONFIG_SMS_USB_DRV=m
CONFIG_DVB_B2C2_FLEXCOP_USB=m
# CONFIG_DVB_B2C2_FLEXCOP_USB_DEBUG is not set
# CONFIG_DVB_AS102 is not set

#
# Webcam, TV (analog/digital) USB devices
#
CONFIG_VIDEO_EM28XX=m
# CONFIG_VIDEO_EM28XX_V4L2 is not set
CONFIG_VIDEO_EM28XX_ALSA=m
CONFIG_VIDEO_EM28XX_DVB=m
CONFIG_VIDEO_EM28XX_RC=m
CONFIG_MEDIA_PCI_SUPPORT=y

#
# Media capture support
#
# CONFIG_VIDEO_MEYE is not set
# CONFIG_VIDEO_SOLO6X10 is not set
# CONFIG_VIDEO_TW5864 is not set
# CONFIG_VIDEO_TW68 is not set
# CONFIG_VIDEO_TW686X is not set
# CONFIG_VIDEO_ZORAN is not set

#
# Media capture/analog TV support
#
CONFIG_VIDEO_IVTV=m
# CONFIG_VIDEO_IVTV_DEPRECATED_IOCTLS is not set
# CONFIG_VIDEO_IVTV_ALSA is not set
CONFIG_VIDEO_FB_IVTV=m
# CONFIG_VIDEO_HEXIUM_GEMINI is not set
# CONFIG_VIDEO_HEXIUM_ORION is not set
# CONFIG_VIDEO_MXB is not set
# CONFIG_VIDEO_DT3155 is not set

#
# Media capture/analog/hybrid TV support
#
CONFIG_VIDEO_CX18=m
CONFIG_VIDEO_CX18_ALSA=m
CONFIG_VIDEO_CX23885=m
CONFIG_MEDIA_ALTERA_CI=m
# CONFIG_VIDEO_CX25821 is not set
CONFIG_VIDEO_CX88=m
CONFIG_VIDEO_CX88_ALSA=m
CONFIG_VIDEO_CX88_BLACKBIRD=m
CONFIG_VIDEO_CX88_DVB=m
CONFIG_VIDEO_CX88_ENABLE_VP3054=y
CONFIG_VIDEO_CX88_VP3054=m
CONFIG_VIDEO_CX88_MPEG=m
CONFIG_VIDEO_BT848=m
CONFIG_DVB_BT8XX=m
CONFIG_VIDEO_SAA7134=m
CONFIG_VIDEO_SAA7134_ALSA=m
CONFIG_VIDEO_SAA7134_RC=y
CONFIG_VIDEO_SAA7134_DVB=m
CONFIG_VIDEO_SAA7164=m

#
# Media digital TV PCI Adapters
#
CONFIG_DVB_AV7110_IR=y
CONFIG_DVB_AV7110=m
CONFIG_DVB_AV7110_OSD=y
CONFIG_DVB_BUDGET_CORE=m
CONFIG_DVB_BUDGET=m
CONFIG_DVB_BUDGET_CI=m
CONFIG_DVB_BUDGET_AV=m
CONFIG_DVB_BUDGET_PATCH=m
CONFIG_DVB_B2C2_FLEXCOP_PCI=m
# CONFIG_DVB_B2C2_FLEXCOP_PCI_DEBUG is not set
CONFIG_DVB_PLUTO2=m
CONFIG_DVB_DM1105=m
CONFIG_DVB_PT1=m
# CONFIG_DVB_PT3 is not set
CONFIG_MANTIS_CORE=m
CONFIG_DVB_MANTIS=m
CONFIG_DVB_HOPPER=m
CONFIG_DVB_NGENE=m
CONFIG_DVB_DDBRIDGE=m
# CONFIG_DVB_SMIPCIE is not set
# CONFIG_DVB_NETUP_UNIDVB is not set
# CONFIG_V4L_PLATFORM_DRIVERS is not set
# CONFIG_V4L_MEM2MEM_DRIVERS is not set
# CONFIG_V4L_TEST_DRIVERS is not set
# CONFIG_DVB_PLATFORM_DRIVERS is not set

#
# Supported MMC/SDIO adapters
#
CONFIG_SMS_SDIO_DRV=m
CONFIG_RADIO_ADAPTERS=y
CONFIG_RADIO_TEA575X=m
# CONFIG_RADIO_SI470X is not set
# CONFIG_RADIO_SI4713 is not set
# CONFIG_USB_MR800 is not set
# CONFIG_USB_DSBR is not set
# CONFIG_RADIO_MAXIRADIO is not set
# CONFIG_RADIO_SHARK is not set
# CONFIG_RADIO_SHARK2 is not set
# CONFIG_USB_KEENE is not set
# CONFIG_USB_RAREMONO is not set
# CONFIG_USB_MA901 is not set
# CONFIG_RADIO_TEA5764 is not set
# CONFIG_RADIO_SAA7706H is not set
# CONFIG_RADIO_TEF6862 is not set
# CONFIG_RADIO_WL1273 is not set

#
# Texas Instruments WL128x FM driver (ST based)
#

#
# Supported FireWire (IEEE 1394) Adapters
#
CONFIG_DVB_FIREDTV=m
CONFIG_DVB_FIREDTV_INPUT=y
CONFIG_MEDIA_COMMON_OPTIONS=y

#
# common driver options
#
CONFIG_VIDEO_CX2341X=m
CONFIG_VIDEO_TVEEPROM=m
CONFIG_CYPRESS_FIRMWARE=m
CONFIG_DVB_B2C2_FLEXCOP=m
CONFIG_VIDEO_SAA7146=m
CONFIG_VIDEO_SAA7146_VV=m
CONFIG_SMS_SIANO_MDTV=m
CONFIG_SMS_SIANO_RC=y
# CONFIG_SMS_SIANO_DEBUGFS is not set

#
# Media ancillary drivers (tuners, sensors, i2c, spi, frontends)
#
CONFIG_MEDIA_SUBDRV_AUTOSELECT=y
CONFIG_MEDIA_ATTACH=y
CONFIG_VIDEO_IR_I2C=m

#
# Audio decoders, processors and mixers
#
CONFIG_VIDEO_TVAUDIO=m
CONFIG_VIDEO_TDA7432=m
CONFIG_VIDEO_MSP3400=m
CONFIG_VIDEO_CS3308=m
CONFIG_VIDEO_CS5345=m
CONFIG_VIDEO_CS53L32A=m
CONFIG_VIDEO_WM8775=m
CONFIG_VIDEO_WM8739=m
CONFIG_VIDEO_VP27SMPX=m

#
# RDS decoders
#
CONFIG_VIDEO_SAA6588=m

#
# Video decoders
#
CONFIG_VIDEO_SAA711X=m

#
# Video and audio decoders
#
CONFIG_VIDEO_SAA717X=m
CONFIG_VIDEO_CX25840=m

#
# Video encoders
#
CONFIG_VIDEO_SAA7127=m

#
# Camera sensor devices
#

#
# Flash devices
#

#
# Video improvement chips
#
CONFIG_VIDEO_UPD64031A=m
CONFIG_VIDEO_UPD64083=m

#
# Audio/Video compression chips
#
CONFIG_VIDEO_SAA6752HS=m

#
# Miscellaneous helper chips
#
CONFIG_VIDEO_M52790=m

#
# Sensors used on soc_camera driver
#
CONFIG_MEDIA_TUNER=m
CONFIG_MEDIA_TUNER_SIMPLE=m
CONFIG_MEDIA_TUNER_TDA8290=m
CONFIG_MEDIA_TUNER_TDA827X=m
CONFIG_MEDIA_TUNER_TDA18271=m
CONFIG_MEDIA_TUNER_TDA9887=m
CONFIG_MEDIA_TUNER_TEA5761=m
CONFIG_MEDIA_TUNER_TEA5767=m
CONFIG_MEDIA_TUNER_MT20XX=m
CONFIG_MEDIA_TUNER_MT2060=m
CONFIG_MEDIA_TUNER_MT2063=m
CONFIG_MEDIA_TUNER_MT2266=m
CONFIG_MEDIA_TUNER_MT2131=m
CONFIG_MEDIA_TUNER_QT1010=m
CONFIG_MEDIA_TUNER_XC2028=m
CONFIG_MEDIA_TUNER_XC5000=m
CONFIG_MEDIA_TUNER_XC4000=m
CONFIG_MEDIA_TUNER_MXL5005S=m
CONFIG_MEDIA_TUNER_MXL5007T=m
CONFIG_MEDIA_TUNER_MC44S803=m
CONFIG_MEDIA_TUNER_MAX2165=m
CONFIG_MEDIA_TUNER_TDA18218=m
CONFIG_MEDIA_TUNER_FC0011=m
CONFIG_MEDIA_TUNER_FC0012=m
CONFIG_MEDIA_TUNER_FC0013=m
CONFIG_MEDIA_TUNER_TDA18212=m
CONFIG_MEDIA_TUNER_E4000=m
CONFIG_MEDIA_TUNER_FC2580=m
CONFIG_MEDIA_TUNER_M88RS6000T=m
CONFIG_MEDIA_TUNER_TUA9001=m
CONFIG_MEDIA_TUNER_SI2157=m
CONFIG_MEDIA_TUNER_IT913X=m
CONFIG_MEDIA_TUNER_R820T=m
CONFIG_MEDIA_TUNER_QM1D1C0042=m

#
# Multistandard (satellite) frontends
#
CONFIG_DVB_STB0899=m
CONFIG_DVB_STB6100=m
CONFIG_DVB_STV090x=m
CONFIG_DVB_STV6110x=m
CONFIG_DVB_M88DS3103=m

#
# Multistandard (cable + terrestrial) frontends
#
CONFIG_DVB_DRXK=m
CONFIG_DVB_TDA18271C2DD=m
CONFIG_DVB_SI2165=m
CONFIG_DVB_MN88472=m
CONFIG_DVB_MN88473=m

#
# DVB-S (satellite) frontends
#
CONFIG_DVB_CX24110=m
CONFIG_DVB_CX24123=m
CONFIG_DVB_MT312=m
CONFIG_DVB_ZL10036=m
CONFIG_DVB_ZL10039=m
CONFIG_DVB_S5H1420=m
CONFIG_DVB_STV0288=m
CONFIG_DVB_STB6000=m
CONFIG_DVB_STV0299=m
CONFIG_DVB_STV6110=m
CONFIG_DVB_STV0900=m
CONFIG_DVB_TDA8083=m
CONFIG_DVB_TDA10086=m
CONFIG_DVB_TDA8261=m
CONFIG_DVB_VES1X93=m
CONFIG_DVB_TUNER_ITD1000=m
CONFIG_DVB_TUNER_CX24113=m
CONFIG_DVB_TDA826X=m
CONFIG_DVB_TUA6100=m
CONFIG_DVB_CX24116=m
CONFIG_DVB_CX24117=m
CONFIG_DVB_CX24120=m
CONFIG_DVB_SI21XX=m
CONFIG_DVB_TS2020=m
CONFIG_DVB_DS3000=m
CONFIG_DVB_MB86A16=m
CONFIG_DVB_TDA10071=m

#
# DVB-T (terrestrial) frontends
#
CONFIG_DVB_SP8870=m
CONFIG_DVB_SP887X=m
CONFIG_DVB_CX22700=m
CONFIG_DVB_CX22702=m
CONFIG_DVB_DRXD=m
CONFIG_DVB_L64781=m
CONFIG_DVB_TDA1004X=m
CONFIG_DVB_NXT6000=m
CONFIG_DVB_MT352=m
CONFIG_DVB_ZL10353=m
CONFIG_DVB_DIB3000MB=m
CONFIG_DVB_DIB3000MC=m
CONFIG_DVB_DIB7000M=m
CONFIG_DVB_DIB7000P=m
CONFIG_DVB_TDA10048=m
CONFIG_DVB_AF9013=m
CONFIG_DVB_EC100=m
CONFIG_DVB_STV0367=m
CONFIG_DVB_CXD2820R=m
CONFIG_DVB_RTL2830=m
CONFIG_DVB_RTL2832=m
CONFIG_DVB_SI2168=m
# CONFIG_DVB_AS102_FE is not set
CONFIG_DVB_GP8PSK_FE=m

#
# DVB-C (cable) frontends
#
CONFIG_DVB_VES1820=m
CONFIG_DVB_TDA10021=m
CONFIG_DVB_TDA10023=m
CONFIG_DVB_STV0297=m

#
# ATSC (North American/Korean Terrestrial/Cable DTV) frontends
#
CONFIG_DVB_NXT200X=m
CONFIG_DVB_OR51211=m
CONFIG_DVB_OR51132=m
CONFIG_DVB_BCM3510=m
CONFIG_DVB_LGDT330X=m
CONFIG_DVB_LGDT3305=m
CONFIG_DVB_LGDT3306A=m
CONFIG_DVB_LG2160=m
CONFIG_DVB_S5H1409=m
CONFIG_DVB_AU8522=m
CONFIG_DVB_AU8522_DTV=m
CONFIG_DVB_AU8522_V4L=m
CONFIG_DVB_S5H1411=m

#
# ISDB-T (terrestrial) frontends
#
CONFIG_DVB_S921=m
CONFIG_DVB_DIB8000=m
CONFIG_DVB_MB86A20S=m

#
# ISDB-S (satellite) & ISDB-T (terrestrial) frontends
#
CONFIG_DVB_TC90522=m

#
# Digital terrestrial only tuners/PLL
#
CONFIG_DVB_PLL=m
CONFIG_DVB_TUNER_DIB0070=m
CONFIG_DVB_TUNER_DIB0090=m

#
# SEC control devices for DVB-S
#
CONFIG_DVB_DRX39XYJ=m
CONFIG_DVB_LNBP21=m
CONFIG_DVB_LNBP22=m
CONFIG_DVB_ISL6405=m
CONFIG_DVB_ISL6421=m
CONFIG_DVB_ISL6423=m
CONFIG_DVB_A8293=m
CONFIG_DVB_LGS8GXX=m
CONFIG_DVB_ATBM8830=m
CONFIG_DVB_TDA665x=m
CONFIG_DVB_IX2505V=m
CONFIG_DVB_M88RS2000=m
CONFIG_DVB_AF9033=m

#
# Tools to develop new frontends
#
# CONFIG_DVB_DUMMY_FE is not set

#
# Graphics support
#
CONFIG_AGP=y
CONFIG_AGP_AMD64=y
CONFIG_AGP_INTEL=y
CONFIG_AGP_SIS=y
CONFIG_AGP_VIA=y
CONFIG_INTEL_GTT=y
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=64
CONFIG_VGA_SWITCHEROO=y
CONFIG_DRM=m
CONFIG_DRM_MIPI_DSI=y
# CONFIG_DRM_DP_AUX_CHARDEV is not set
# CONFIG_DRM_DEBUG_MM_SELFTEST is not set
CONFIG_DRM_KMS_HELPER=m
CONFIG_DRM_KMS_FB_HELPER=y
CONFIG_DRM_FBDEV_EMULATION=y
CONFIG_DRM_LOAD_EDID_FIRMWARE=y
CONFIG_DRM_TTM=m

#
# I2C encoder or helper chips
#
CONFIG_DRM_I2C_CH7006=m
CONFIG_DRM_I2C_SIL164=m
CONFIG_DRM_I2C_NXP_TDA998X=m
# CONFIG_DRM_RADEON is not set
# CONFIG_DRM_AMDGPU is not set

#
# ACP (Audio CoProcessor) Configuration
#
# CONFIG_DRM_NOUVEAU is not set
CONFIG_DRM_I915=m
# CONFIG_DRM_I915_ALPHA_SUPPORT is not set
CONFIG_DRM_I915_CAPTURE_ERROR=y
CONFIG_DRM_I915_COMPRESS_ERROR=y
CONFIG_DRM_I915_USERPTR=y
# CONFIG_DRM_I915_GVT is not set

#
# drm/i915 Debugging
#
# CONFIG_DRM_I915_WERROR is not set
# CONFIG_DRM_I915_DEBUG is not set
# CONFIG_DRM_I915_SW_FENCE_DEBUG_OBJECTS is not set
# CONFIG_DRM_VGEM is not set
CONFIG_DRM_VMWGFX=m
CONFIG_DRM_VMWGFX_FBCON=y
CONFIG_DRM_GMA500=m
CONFIG_DRM_GMA600=y
CONFIG_DRM_GMA3600=y
CONFIG_DRM_UDL=m
CONFIG_DRM_AST=m
CONFIG_DRM_MGAG200=m
CONFIG_DRM_CIRRUS_QEMU=m
CONFIG_DRM_QXL=m
# CONFIG_DRM_BOCHS is not set
# CONFIG_DRM_VIRTIO_GPU is not set
CONFIG_DRM_PANEL=y

#
# Display Panels
#
CONFIG_DRM_BRIDGE=y

#
# Display Interface Bridges
#
# CONFIG_DRM_ANALOGIX_ANX78XX is not set
# CONFIG_DRM_HISI_HIBMC is not set
# CONFIG_DRM_TINYDRM is not set
# CONFIG_DRM_LEGACY is not set
# CONFIG_DRM_LIB_RANDOM is not set

#
# Frame buffer Devices
#
CONFIG_FB=y
# CONFIG_FIRMWARE_EDID is not set
CONFIG_FB_CMDLINE=y
CONFIG_FB_NOTIFY=y
# CONFIG_FB_DDC is not set
CONFIG_FB_BOOT_VESA_SUPPORT=y
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
CONFIG_FB_SYS_FILLRECT=m
CONFIG_FB_SYS_COPYAREA=m
CONFIG_FB_SYS_IMAGEBLIT=m
# CONFIG_FB_PROVIDE_GET_FB_UNMAPPED_AREA is not set
# CONFIG_FB_FOREIGN_ENDIAN is not set
CONFIG_FB_SYS_FOPS=m
CONFIG_FB_DEFERRED_IO=y
# CONFIG_FB_SVGALIB is not set
# CONFIG_FB_MACMODES is not set
# CONFIG_FB_BACKLIGHT is not set
# CONFIG_FB_MODE_HELPERS is not set
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
# CONFIG_FB_PM2 is not set
# CONFIG_FB_CYBER2000 is not set
# CONFIG_FB_ARC is not set
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
# CONFIG_FB_UVESA is not set
CONFIG_FB_VESA=y
CONFIG_FB_EFI=y
# CONFIG_FB_N411 is not set
# CONFIG_FB_HGA is not set
# CONFIG_FB_OPENCORES is not set
# CONFIG_FB_S1D13XXX is not set
# CONFIG_FB_NVIDIA is not set
# CONFIG_FB_RIVA is not set
# CONFIG_FB_I740 is not set
# CONFIG_FB_LE80578 is not set
# CONFIG_FB_INTEL is not set
# CONFIG_FB_MATROX is not set
# CONFIG_FB_RADEON is not set
# CONFIG_FB_ATY128 is not set
# CONFIG_FB_ATY is not set
# CONFIG_FB_S3 is not set
# CONFIG_FB_SAVAGE is not set
# CONFIG_FB_SIS is not set
# CONFIG_FB_VIA is not set
# CONFIG_FB_NEOMAGIC is not set
# CONFIG_FB_KYRO is not set
# CONFIG_FB_3DFX is not set
# CONFIG_FB_VOODOO1 is not set
# CONFIG_FB_VT8623 is not set
# CONFIG_FB_TRIDENT is not set
# CONFIG_FB_ARK is not set
# CONFIG_FB_PM3 is not set
# CONFIG_FB_CARMINE is not set
# CONFIG_FB_SM501 is not set
# CONFIG_FB_SMSCUFX is not set
# CONFIG_FB_UDL is not set
# CONFIG_FB_IBM_GXT4500 is not set
# CONFIG_FB_VIRTUAL is not set
# CONFIG_XEN_FBDEV_FRONTEND is not set
# CONFIG_FB_METRONOME is not set
# CONFIG_FB_MB862XX is not set
# CONFIG_FB_BROADSHEET is not set
# CONFIG_FB_AUO_K190X is not set
CONFIG_FB_HYPERV=m
# CONFIG_FB_SIMPLE is not set
# CONFIG_FB_SM712 is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=m
# CONFIG_LCD_L4F00242T03 is not set
# CONFIG_LCD_LMS283GF05 is not set
# CONFIG_LCD_LTV350QV is not set
# CONFIG_LCD_ILI922X is not set
# CONFIG_LCD_ILI9320 is not set
# CONFIG_LCD_TDO24M is not set
# CONFIG_LCD_VGG2432A4 is not set
CONFIG_LCD_PLATFORM=m
# CONFIG_LCD_S6E63M0 is not set
# CONFIG_LCD_LD9040 is not set
# CONFIG_LCD_AMS369FG06 is not set
# CONFIG_LCD_LMS501KF03 is not set
# CONFIG_LCD_HX8357 is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
# CONFIG_BACKLIGHT_GENERIC is not set
# CONFIG_BACKLIGHT_PWM is not set
CONFIG_BACKLIGHT_APPLE=m
# CONFIG_BACKLIGHT_PM8941_WLED is not set
# CONFIG_BACKLIGHT_SAHARA is not set
# CONFIG_BACKLIGHT_ADP8860 is not set
# CONFIG_BACKLIGHT_ADP8870 is not set
# CONFIG_BACKLIGHT_LM3630A is not set
# CONFIG_BACKLIGHT_LM3639 is not set
# CONFIG_BACKLIGHT_LP855X is not set
# CONFIG_BACKLIGHT_GPIO is not set
# CONFIG_BACKLIGHT_LV5207LP is not set
# CONFIG_BACKLIGHT_BD6107 is not set
# CONFIG_VGASTATE is not set
CONFIG_HDMI=y

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
CONFIG_VGACON_SOFT_SCROLLBACK=y
CONFIG_VGACON_SOFT_SCROLLBACK_SIZE=64
# CONFIG_VGACON_SOFT_SCROLLBACK_PERSISTENT_ENABLE_BY_DEFAULT is not set
CONFIG_DUMMY_CONSOLE=y
CONFIG_DUMMY_CONSOLE_COLUMNS=80
CONFIG_DUMMY_CONSOLE_ROWS=25
CONFIG_FRAMEBUFFER_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE_DETECT_PRIMARY=y
CONFIG_FRAMEBUFFER_CONSOLE_ROTATION=y
CONFIG_LOGO=y
# CONFIG_LOGO_LINUX_MONO is not set
# CONFIG_LOGO_LINUX_VGA16 is not set
CONFIG_LOGO_LINUX_CLUT224=y
CONFIG_SOUND=m
CONFIG_SOUND_OSS_CORE=y
CONFIG_SOUND_OSS_CORE_PRECLAIM=y
CONFIG_SND=m
CONFIG_SND_TIMER=m
CONFIG_SND_PCM=m
CONFIG_SND_HWDEP=m
CONFIG_SND_RAWMIDI=m
CONFIG_SND_JACK=y
CONFIG_SND_JACK_INPUT_DEV=y
CONFIG_SND_SEQUENCER=m
CONFIG_SND_SEQ_DUMMY=m
CONFIG_SND_OSSEMUL=y
# CONFIG_SND_MIXER_OSS is not set
# CONFIG_SND_PCM_OSS is not set
CONFIG_SND_PCM_TIMER=y
CONFIG_SND_SEQUENCER_OSS=y
CONFIG_SND_HRTIMER=m
CONFIG_SND_SEQ_HRTIMER_DEFAULT=y
CONFIG_SND_DYNAMIC_MINORS=y
CONFIG_SND_MAX_CARDS=32
# CONFIG_SND_SUPPORT_OLD_API is not set
CONFIG_SND_PROC_FS=y
CONFIG_SND_VERBOSE_PROCFS=y
# CONFIG_SND_VERBOSE_PRINTK is not set
# CONFIG_SND_DEBUG is not set
CONFIG_SND_VMASTER=y
CONFIG_SND_DMA_SGBUF=y
CONFIG_SND_RAWMIDI_SEQ=m
CONFIG_SND_OPL3_LIB_SEQ=m
# CONFIG_SND_OPL4_LIB_SEQ is not set
# CONFIG_SND_SBAWE_SEQ is not set
CONFIG_SND_EMU10K1_SEQ=m
CONFIG_SND_MPU401_UART=m
CONFIG_SND_OPL3_LIB=m
CONFIG_SND_VX_LIB=m
CONFIG_SND_AC97_CODEC=m
CONFIG_SND_DRIVERS=y
CONFIG_SND_PCSP=m
CONFIG_SND_DUMMY=m
CONFIG_SND_ALOOP=m
CONFIG_SND_VIRMIDI=m
CONFIG_SND_MTPAV=m
# CONFIG_SND_MTS64 is not set
# CONFIG_SND_SERIAL_U16550 is not set
CONFIG_SND_MPU401=m
# CONFIG_SND_PORTMAN2X4 is not set
CONFIG_SND_AC97_POWER_SAVE=y
CONFIG_SND_AC97_POWER_SAVE_DEFAULT=5
CONFIG_SND_PCI=y
CONFIG_SND_AD1889=m
# CONFIG_SND_ALS300 is not set
# CONFIG_SND_ALS4000 is not set
CONFIG_SND_ALI5451=m
CONFIG_SND_ASIHPI=m
CONFIG_SND_ATIIXP=m
CONFIG_SND_ATIIXP_MODEM=m
CONFIG_SND_AU8810=m
CONFIG_SND_AU8820=m
CONFIG_SND_AU8830=m
# CONFIG_SND_AW2 is not set
# CONFIG_SND_AZT3328 is not set
CONFIG_SND_BT87X=m
# CONFIG_SND_BT87X_OVERCLOCK is not set
CONFIG_SND_CA0106=m
CONFIG_SND_CMIPCI=m
CONFIG_SND_OXYGEN_LIB=m
CONFIG_SND_OXYGEN=m
# CONFIG_SND_CS4281 is not set
CONFIG_SND_CS46XX=m
CONFIG_SND_CS46XX_NEW_DSP=y
CONFIG_SND_CTXFI=m
CONFIG_SND_DARLA20=m
CONFIG_SND_GINA20=m
CONFIG_SND_LAYLA20=m
CONFIG_SND_DARLA24=m
CONFIG_SND_GINA24=m
CONFIG_SND_LAYLA24=m
CONFIG_SND_MONA=m
CONFIG_SND_MIA=m
CONFIG_SND_ECHO3G=m
CONFIG_SND_INDIGO=m
CONFIG_SND_INDIGOIO=m
CONFIG_SND_INDIGODJ=m
CONFIG_SND_INDIGOIOX=m
CONFIG_SND_INDIGODJX=m
CONFIG_SND_EMU10K1=m
CONFIG_SND_EMU10K1X=m
CONFIG_SND_ENS1370=m
CONFIG_SND_ENS1371=m
# CONFIG_SND_ES1938 is not set
CONFIG_SND_ES1968=m
CONFIG_SND_ES1968_INPUT=y
CONFIG_SND_ES1968_RADIO=y
# CONFIG_SND_FM801 is not set
CONFIG_SND_HDSP=m
CONFIG_SND_HDSPM=m
CONFIG_SND_ICE1712=m
CONFIG_SND_ICE1724=m
CONFIG_SND_INTEL8X0=m
CONFIG_SND_INTEL8X0M=m
CONFIG_SND_KORG1212=m
CONFIG_SND_LOLA=m
CONFIG_SND_LX6464ES=m
CONFIG_SND_MAESTRO3=m
CONFIG_SND_MAESTRO3_INPUT=y
CONFIG_SND_MIXART=m
# CONFIG_SND_NM256 is not set
CONFIG_SND_PCXHR=m
# CONFIG_SND_RIPTIDE is not set
CONFIG_SND_RME32=m
CONFIG_SND_RME96=m
CONFIG_SND_RME9652=m
# CONFIG_SND_SONICVIBES is not set
CONFIG_SND_TRIDENT=m
CONFIG_SND_VIA82XX=m
CONFIG_SND_VIA82XX_MODEM=m
CONFIG_SND_VIRTUOSO=m
CONFIG_SND_VX222=m
# CONFIG_SND_YMFPCI is not set

#
# HD-Audio
#
CONFIG_SND_HDA=m
CONFIG_SND_HDA_INTEL=m
CONFIG_SND_HDA_HWDEP=y
# CONFIG_SND_HDA_RECONFIG is not set
CONFIG_SND_HDA_INPUT_BEEP=y
CONFIG_SND_HDA_INPUT_BEEP_MODE=0
# CONFIG_SND_HDA_PATCH_LOADER is not set
CONFIG_SND_HDA_CODEC_REALTEK=m
CONFIG_SND_HDA_CODEC_ANALOG=m
CONFIG_SND_HDA_CODEC_SIGMATEL=m
CONFIG_SND_HDA_CODEC_VIA=m
CONFIG_SND_HDA_CODEC_HDMI=m
CONFIG_SND_HDA_CODEC_CIRRUS=m
CONFIG_SND_HDA_CODEC_CONEXANT=m
CONFIG_SND_HDA_CODEC_CA0110=m
CONFIG_SND_HDA_CODEC_CA0132=m
CONFIG_SND_HDA_CODEC_CA0132_DSP=y
CONFIG_SND_HDA_CODEC_CMEDIA=m
CONFIG_SND_HDA_CODEC_SI3054=m
CONFIG_SND_HDA_GENERIC=m
CONFIG_SND_HDA_POWER_SAVE_DEFAULT=0
CONFIG_SND_HDA_CORE=m
CONFIG_SND_HDA_DSP_LOADER=y
CONFIG_SND_HDA_I915=y
CONFIG_SND_HDA_PREALLOC_SIZE=512
CONFIG_SND_SPI=y
CONFIG_SND_USB=y
CONFIG_SND_USB_AUDIO=m
CONFIG_SND_USB_UA101=m
CONFIG_SND_USB_USX2Y=m
CONFIG_SND_USB_CAIAQ=m
CONFIG_SND_USB_CAIAQ_INPUT=y
CONFIG_SND_USB_US122L=m
CONFIG_SND_USB_6FIRE=m
# CONFIG_SND_USB_HIFACE is not set
# CONFIG_SND_BCD2000 is not set
# CONFIG_SND_USB_POD is not set
# CONFIG_SND_USB_PODHD is not set
# CONFIG_SND_USB_TONEPORT is not set
# CONFIG_SND_USB_VARIAX is not set
CONFIG_SND_FIREWIRE=y
CONFIG_SND_FIREWIRE_LIB=m
# CONFIG_SND_DICE is not set
# CONFIG_SND_OXFW is not set
CONFIG_SND_ISIGHT=m
# CONFIG_SND_FIREWORKS is not set
# CONFIG_SND_BEBOB is not set
# CONFIG_SND_FIREWIRE_DIGI00X is not set
# CONFIG_SND_FIREWIRE_TASCAM is not set
# CONFIG_SND_SOC is not set
CONFIG_SND_X86=y
# CONFIG_HDMI_LPE_AUDIO is not set
# CONFIG_SOUND_PRIME is not set
CONFIG_AC97_BUS=m

#
# HID support
#
CONFIG_HID=y
CONFIG_HID_BATTERY_STRENGTH=y
CONFIG_HIDRAW=y
CONFIG_UHID=m
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
CONFIG_HID_A4TECH=y
CONFIG_HID_ACRUX=m
# CONFIG_HID_ACRUX_FF is not set
CONFIG_HID_APPLE=y
CONFIG_HID_APPLEIR=m
# CONFIG_HID_ASUS is not set
CONFIG_HID_AUREAL=m
CONFIG_HID_BELKIN=y
# CONFIG_HID_BETOP_FF is not set
CONFIG_HID_CHERRY=y
CONFIG_HID_CHICONY=y
# CONFIG_HID_CORSAIR is not set
CONFIG_HID_PRODIKEYS=m
# CONFIG_HID_CMEDIA is not set
# CONFIG_HID_CP2112 is not set
CONFIG_HID_CYPRESS=y
CONFIG_HID_DRAGONRISE=m
# CONFIG_DRAGONRISE_FF is not set
# CONFIG_HID_EMS_FF is not set
CONFIG_HID_ELECOM=m
# CONFIG_HID_ELO is not set
CONFIG_HID_EZKEY=y
# CONFIG_HID_GEMBIRD is not set
# CONFIG_HID_GFRM is not set
CONFIG_HID_HOLTEK=m
# CONFIG_HOLTEK_FF is not set
# CONFIG_HID_GT683R is not set
CONFIG_HID_KEYTOUCH=m
CONFIG_HID_KYE=m
CONFIG_HID_UCLOGIC=m
CONFIG_HID_WALTOP=m
CONFIG_HID_GYRATION=m
CONFIG_HID_ICADE=m
CONFIG_HID_TWINHAN=m
CONFIG_HID_KENSINGTON=y
CONFIG_HID_LCPOWER=m
CONFIG_HID_LED=m
# CONFIG_HID_LENOVO is not set
CONFIG_HID_LOGITECH=y
CONFIG_HID_LOGITECH_DJ=m
CONFIG_HID_LOGITECH_HIDPP=m
# CONFIG_LOGITECH_FF is not set
# CONFIG_LOGIRUMBLEPAD2_FF is not set
# CONFIG_LOGIG940_FF is not set
# CONFIG_LOGIWHEELS_FF is not set
CONFIG_HID_MAGICMOUSE=y
# CONFIG_HID_MAYFLASH is not set
CONFIG_HID_MICROSOFT=y
CONFIG_HID_MONTEREY=y
CONFIG_HID_MULTITOUCH=m
CONFIG_HID_NTRIG=y
CONFIG_HID_ORTEK=m
CONFIG_HID_PANTHERLORD=m
# CONFIG_PANTHERLORD_FF is not set
# CONFIG_HID_PENMOUNT is not set
CONFIG_HID_PETALYNX=m
CONFIG_HID_PICOLCD=m
CONFIG_HID_PICOLCD_FB=y
CONFIG_HID_PICOLCD_BACKLIGHT=y
CONFIG_HID_PICOLCD_LCD=y
CONFIG_HID_PICOLCD_LEDS=y
CONFIG_HID_PICOLCD_CIR=y
CONFIG_HID_PLANTRONICS=y
CONFIG_HID_PRIMAX=m
CONFIG_HID_ROCCAT=m
CONFIG_HID_SAITEK=m
CONFIG_HID_SAMSUNG=m
CONFIG_HID_SONY=m
# CONFIG_SONY_FF is not set
CONFIG_HID_SPEEDLINK=m
CONFIG_HID_STEELSERIES=m
CONFIG_HID_SUNPLUS=m
# CONFIG_HID_RMI is not set
CONFIG_HID_GREENASIA=m
# CONFIG_GREENASIA_FF is not set
CONFIG_HID_HYPERV_MOUSE=m
CONFIG_HID_SMARTJOYPLUS=m
# CONFIG_SMARTJOYPLUS_FF is not set
CONFIG_HID_TIVO=m
CONFIG_HID_TOPSEED=m
CONFIG_HID_THINGM=m
CONFIG_HID_THRUSTMASTER=m
# CONFIG_THRUSTMASTER_FF is not set
# CONFIG_HID_UDRAW_PS3 is not set
CONFIG_HID_WACOM=m
CONFIG_HID_WIIMOTE=m
# CONFIG_HID_XINMO is not set
CONFIG_HID_ZEROPLUS=m
# CONFIG_ZEROPLUS_FF is not set
CONFIG_HID_ZYDACRON=m
# CONFIG_HID_SENSOR_HUB is not set
# CONFIG_HID_ALPS is not set

#
# USB HID support
#
CONFIG_USB_HID=y
CONFIG_HID_PID=y
CONFIG_USB_HIDDEV=y

#
# I2C HID support
#
CONFIG_I2C_HID=m

#
# Intel ISH HID support
#
# CONFIG_INTEL_ISH_HID is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=y
CONFIG_USB_ANNOUNCE_NEW_DEVICES=y

#
# Miscellaneous USB options
#
CONFIG_USB_DEFAULT_PERSIST=y
# CONFIG_USB_DYNAMIC_MINORS is not set
# CONFIG_USB_OTG is not set
# CONFIG_USB_OTG_WHITELIST is not set
# CONFIG_USB_OTG_BLACKLIST_HUB is not set
# CONFIG_USB_LEDS_TRIGGER_USBPORT is not set
CONFIG_USB_MON=y
CONFIG_USB_WUSB=m
CONFIG_USB_WUSB_CBAF=m
# CONFIG_USB_WUSB_CBAF_DEBUG is not set

#
# USB Host Controller Drivers
#
# CONFIG_USB_C67X00_HCD is not set
CONFIG_USB_XHCI_HCD=y
CONFIG_USB_XHCI_PCI=y
CONFIG_USB_XHCI_PLATFORM=y
CONFIG_USB_EHCI_HCD=y
CONFIG_USB_EHCI_ROOT_HUB_TT=y
CONFIG_USB_EHCI_TT_NEWSCHED=y
CONFIG_USB_EHCI_PCI=y
# CONFIG_USB_EHCI_HCD_PLATFORM is not set
# CONFIG_USB_OXU210HP_HCD is not set
# CONFIG_USB_ISP116X_HCD is not set
# CONFIG_USB_ISP1362_HCD is not set
# CONFIG_USB_FOTG210_HCD is not set
# CONFIG_USB_MAX3421_HCD is not set
CONFIG_USB_OHCI_HCD=y
CONFIG_USB_OHCI_HCD_PCI=y
# CONFIG_USB_OHCI_HCD_PLATFORM is not set
CONFIG_USB_UHCI_HCD=y
# CONFIG_USB_U132_HCD is not set
# CONFIG_USB_SL811_HCD is not set
# CONFIG_USB_R8A66597_HCD is not set
# CONFIG_USB_WHCI_HCD is not set
CONFIG_USB_HWA_HCD=m
# CONFIG_USB_HCD_BCMA is not set
# CONFIG_USB_HCD_SSB is not set
# CONFIG_USB_HCD_TEST_MODE is not set

#
# USB Device Class drivers
#
CONFIG_USB_ACM=m
CONFIG_USB_PRINTER=m
CONFIG_USB_WDM=m
CONFIG_USB_TMC=m

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#
CONFIG_USB_STORAGE=m
# CONFIG_USB_STORAGE_DEBUG is not set
CONFIG_USB_STORAGE_REALTEK=m
CONFIG_REALTEK_AUTOPM=y
CONFIG_USB_STORAGE_DATAFAB=m
CONFIG_USB_STORAGE_FREECOM=m
CONFIG_USB_STORAGE_ISD200=m
CONFIG_USB_STORAGE_USBAT=m
CONFIG_USB_STORAGE_SDDR09=m
CONFIG_USB_STORAGE_SDDR55=m
CONFIG_USB_STORAGE_JUMPSHOT=m
CONFIG_USB_STORAGE_ALAUDA=m
CONFIG_USB_STORAGE_ONETOUCH=m
CONFIG_USB_STORAGE_KARMA=m
CONFIG_USB_STORAGE_CYPRESS_ATACB=m
CONFIG_USB_STORAGE_ENE_UB6250=m
CONFIG_USB_UAS=m

#
# USB Imaging devices
#
CONFIG_USB_MDC800=m
CONFIG_USB_MICROTEK=m
# CONFIG_USBIP_CORE is not set
# CONFIG_USB_MUSB_HDRC is not set
CONFIG_USB_DWC3=y
# CONFIG_USB_DWC3_HOST is not set
CONFIG_USB_DWC3_GADGET=y
# CONFIG_USB_DWC3_DUAL_ROLE is not set

#
# Platform Glue Driver Support
#
CONFIG_USB_DWC3_PCI=y
# CONFIG_USB_DWC2 is not set
# CONFIG_USB_CHIPIDEA is not set
# CONFIG_USB_ISP1760 is not set

#
# USB port drivers
#
CONFIG_USB_USS720=m
CONFIG_USB_SERIAL=y
CONFIG_USB_SERIAL_CONSOLE=y
CONFIG_USB_SERIAL_GENERIC=y
# CONFIG_USB_SERIAL_SIMPLE is not set
CONFIG_USB_SERIAL_AIRCABLE=m
CONFIG_USB_SERIAL_ARK3116=m
CONFIG_USB_SERIAL_BELKIN=m
CONFIG_USB_SERIAL_CH341=m
CONFIG_USB_SERIAL_WHITEHEAT=m
CONFIG_USB_SERIAL_DIGI_ACCELEPORT=m
CONFIG_USB_SERIAL_CP210X=m
CONFIG_USB_SERIAL_CYPRESS_M8=m
CONFIG_USB_SERIAL_EMPEG=m
CONFIG_USB_SERIAL_FTDI_SIO=m
CONFIG_USB_SERIAL_VISOR=m
CONFIG_USB_SERIAL_IPAQ=m
CONFIG_USB_SERIAL_IR=m
CONFIG_USB_SERIAL_EDGEPORT=m
CONFIG_USB_SERIAL_EDGEPORT_TI=m
# CONFIG_USB_SERIAL_F81232 is not set
# CONFIG_USB_SERIAL_F8153X is not set
CONFIG_USB_SERIAL_GARMIN=m
CONFIG_USB_SERIAL_IPW=m
CONFIG_USB_SERIAL_IUU=m
CONFIG_USB_SERIAL_KEYSPAN_PDA=m
CONFIG_USB_SERIAL_KEYSPAN=m
CONFIG_USB_SERIAL_KLSI=m
CONFIG_USB_SERIAL_KOBIL_SCT=m
CONFIG_USB_SERIAL_MCT_U232=m
# CONFIG_USB_SERIAL_METRO is not set
CONFIG_USB_SERIAL_MOS7720=m
CONFIG_USB_SERIAL_MOS7715_PARPORT=y
CONFIG_USB_SERIAL_MOS7840=m
# CONFIG_USB_SERIAL_MXUPORT is not set
CONFIG_USB_SERIAL_NAVMAN=m
CONFIG_USB_SERIAL_PL2303=m
CONFIG_USB_SERIAL_OTI6858=m
CONFIG_USB_SERIAL_QCAUX=m
CONFIG_USB_SERIAL_QUALCOMM=m
CONFIG_USB_SERIAL_SPCP8X5=m
CONFIG_USB_SERIAL_SAFE=m
CONFIG_USB_SERIAL_SAFE_PADDED=y
CONFIG_USB_SERIAL_SIERRAWIRELESS=m
CONFIG_USB_SERIAL_SYMBOL=m
# CONFIG_USB_SERIAL_TI is not set
CONFIG_USB_SERIAL_CYBERJACK=m
CONFIG_USB_SERIAL_XIRCOM=m
CONFIG_USB_SERIAL_WWAN=m
CONFIG_USB_SERIAL_OPTION=m
CONFIG_USB_SERIAL_OMNINET=m
CONFIG_USB_SERIAL_OPTICON=m
CONFIG_USB_SERIAL_XSENS_MT=m
# CONFIG_USB_SERIAL_WISHBONE is not set
CONFIG_USB_SERIAL_SSU100=m
CONFIG_USB_SERIAL_QT2=m
# CONFIG_USB_SERIAL_UPD78F0730 is not set
CONFIG_USB_SERIAL_DEBUG=m

#
# USB Miscellaneous drivers
#
CONFIG_USB_EMI62=m
CONFIG_USB_EMI26=m
CONFIG_USB_ADUTUX=m
CONFIG_USB_SEVSEG=m
# CONFIG_USB_RIO500 is not set
CONFIG_USB_LEGOTOWER=m
CONFIG_USB_LCD=m
# CONFIG_USB_CYPRESS_CY7C63 is not set
# CONFIG_USB_CYTHERM is not set
CONFIG_USB_IDMOUSE=m
CONFIG_USB_FTDI_ELAN=m
CONFIG_USB_APPLEDISPLAY=m
CONFIG_USB_SISUSBVGA=m
CONFIG_USB_SISUSBVGA_CON=y
CONFIG_USB_LD=m
# CONFIG_USB_TRANCEVIBRATOR is not set
CONFIG_USB_IOWARRIOR=m
# CONFIG_USB_TEST is not set
# CONFIG_USB_EHSET_TEST_FIXTURE is not set
CONFIG_USB_ISIGHTFW=m
# CONFIG_USB_YUREX is not set
CONFIG_USB_EZUSB_FX2=m
# CONFIG_USB_HUB_USB251XB is not set
CONFIG_USB_HSIC_USB3503=m
# CONFIG_USB_HSIC_USB4604 is not set
# CONFIG_USB_LINK_LAYER_TEST is not set
# CONFIG_USB_CHAOSKEY is not set
# CONFIG_UCSI is not set
CONFIG_USB_ATM=m
CONFIG_USB_SPEEDTOUCH=m
CONFIG_USB_CXACRU=m
CONFIG_USB_UEAGLEATM=m
CONFIG_USB_XUSBATM=m

#
# USB Physical Layer drivers
#
CONFIG_USB_PHY=y
CONFIG_NOP_USB_XCEIV=y
# CONFIG_USB_GPIO_VBUS is not set
# CONFIG_USB_ISP1301 is not set
CONFIG_USB_GADGET=y
# CONFIG_USB_GADGET_DEBUG is not set
# CONFIG_USB_GADGET_DEBUG_FILES is not set
# CONFIG_USB_GADGET_DEBUG_FS is not set
CONFIG_USB_GADGET_VBUS_DRAW=2
CONFIG_USB_GADGET_STORAGE_NUM_BUFFERS=2

#
# USB Peripheral Controller
#
# CONFIG_USB_FOTG210_UDC is not set
# CONFIG_USB_GR_UDC is not set
# CONFIG_USB_R8A66597 is not set
# CONFIG_USB_PXA27X is not set
# CONFIG_USB_MV_UDC is not set
# CONFIG_USB_MV_U3D is not set
# CONFIG_USB_M66592 is not set
# CONFIG_USB_BDC_UDC is not set
# CONFIG_USB_AMD5536UDC is not set
# CONFIG_USB_NET2272 is not set
# CONFIG_USB_NET2280 is not set
# CONFIG_USB_GOKU is not set
# CONFIG_USB_EG20T is not set
# CONFIG_USB_DUMMY_HCD is not set
CONFIG_USB_LIBCOMPOSITE=m
CONFIG_USB_F_MASS_STORAGE=m
# CONFIG_USB_CONFIGFS is not set
# CONFIG_USB_ZERO is not set
# CONFIG_USB_AUDIO is not set
# CONFIG_USB_ETH is not set
# CONFIG_USB_G_NCM is not set
# CONFIG_USB_GADGETFS is not set
# CONFIG_USB_FUNCTIONFS is not set
CONFIG_USB_MASS_STORAGE=m
# CONFIG_USB_GADGET_TARGET is not set
# CONFIG_USB_G_SERIAL is not set
# CONFIG_USB_MIDI_GADGET is not set
# CONFIG_USB_G_PRINTER is not set
# CONFIG_USB_CDC_COMPOSITE is not set
# CONFIG_USB_G_ACM_MS is not set
# CONFIG_USB_G_MULTI is not set
# CONFIG_USB_G_HID is not set
# CONFIG_USB_G_DBGP is not set
# CONFIG_USB_G_WEBCAM is not set
# CONFIG_USB_LED_TRIG is not set
# CONFIG_USB_ULPI_BUS is not set
CONFIG_UWB=m
CONFIG_UWB_HWA=m
CONFIG_UWB_WHCI=m
CONFIG_UWB_I1480U=m
CONFIG_MMC=m
# CONFIG_MMC_DEBUG is not set
CONFIG_MMC_BLOCK=m
CONFIG_MMC_BLOCK_MINORS=8
CONFIG_MMC_BLOCK_BOUNCE=y
CONFIG_SDIO_UART=m
# CONFIG_MMC_TEST is not set

#
# MMC/SD/SDIO Host Controller Drivers
#
CONFIG_MMC_SDHCI=m
CONFIG_MMC_SDHCI_PCI=m
CONFIG_MMC_RICOH_MMC=y
CONFIG_MMC_SDHCI_ACPI=m
CONFIG_MMC_SDHCI_PLTFM=m
# CONFIG_MMC_WBSD is not set
CONFIG_MMC_TIFM_SD=m
# CONFIG_MMC_SPI is not set
CONFIG_MMC_CB710=m
CONFIG_MMC_VIA_SDMMC=m
CONFIG_MMC_VUB300=m
CONFIG_MMC_USHC=m
# CONFIG_MMC_USDHI6ROL0 is not set
CONFIG_MMC_REALTEK_PCI=m
# CONFIG_MMC_TOSHIBA_PCI is not set
# CONFIG_MMC_MTK is not set
CONFIG_MEMSTICK=m
# CONFIG_MEMSTICK_DEBUG is not set

#
# MemoryStick drivers
#
# CONFIG_MEMSTICK_UNSAFE_RESUME is not set
CONFIG_MSPRO_BLOCK=m
# CONFIG_MS_BLOCK is not set

#
# MemoryStick Host Controller Drivers
#
CONFIG_MEMSTICK_TIFM_MS=m
CONFIG_MEMSTICK_JMICRON_38X=m
CONFIG_MEMSTICK_R592=m
CONFIG_MEMSTICK_REALTEK_PCI=m
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y
# CONFIG_LEDS_CLASS_FLASH is not set
# CONFIG_LEDS_BRIGHTNESS_HW_CHANGED is not set

#
# LED drivers
#
CONFIG_LEDS_LM3530=m
# CONFIG_LEDS_LM3642 is not set
# CONFIG_LEDS_PCA9532 is not set
# CONFIG_LEDS_GPIO is not set
CONFIG_LEDS_LP3944=m
# CONFIG_LEDS_LP3952 is not set
CONFIG_LEDS_LP55XX_COMMON=m
CONFIG_LEDS_LP5521=m
CONFIG_LEDS_LP5523=m
CONFIG_LEDS_LP5562=m
# CONFIG_LEDS_LP8501 is not set
# CONFIG_LEDS_LP8860 is not set
CONFIG_LEDS_CLEVO_MAIL=m
# CONFIG_LEDS_PCA955X is not set
# CONFIG_LEDS_PCA963X is not set
# CONFIG_LEDS_DAC124S085 is not set
# CONFIG_LEDS_PWM is not set
# CONFIG_LEDS_BD2802 is not set
CONFIG_LEDS_INTEL_SS4200=m
# CONFIG_LEDS_LT3593 is not set
# CONFIG_LEDS_TCA6507 is not set
# CONFIG_LEDS_TLC591XX is not set
# CONFIG_LEDS_LM355x is not set

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
CONFIG_LEDS_BLINKM=m
# CONFIG_LEDS_MLXCPLD is not set
# CONFIG_LEDS_USER is not set
# CONFIG_LEDS_NIC78BX is not set

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
CONFIG_LEDS_TRIGGER_TIMER=m
CONFIG_LEDS_TRIGGER_ONESHOT=m
# CONFIG_LEDS_TRIGGER_DISK is not set
# CONFIG_LEDS_TRIGGER_MTD is not set
CONFIG_LEDS_TRIGGER_HEARTBEAT=m
CONFIG_LEDS_TRIGGER_BACKLIGHT=m
# CONFIG_LEDS_TRIGGER_CPU is not set
# CONFIG_LEDS_TRIGGER_GPIO is not set
CONFIG_LEDS_TRIGGER_DEFAULT_ON=m

#
# iptables trigger is under Netfilter config (LED target)
#
CONFIG_LEDS_TRIGGER_TRANSIENT=m
CONFIG_LEDS_TRIGGER_CAMERA=m
# CONFIG_LEDS_TRIGGER_PANIC is not set
# CONFIG_ACCESSIBILITY is not set
# CONFIG_INFINIBAND is not set
CONFIG_EDAC_ATOMIC_SCRUB=y
CONFIG_EDAC_SUPPORT=y
CONFIG_EDAC=y
CONFIG_EDAC_LEGACY_SYSFS=y
# CONFIG_EDAC_DEBUG is not set
CONFIG_EDAC_DECODE_MCE=m
CONFIG_EDAC_MM_EDAC=m
CONFIG_EDAC_AMD64=m
# CONFIG_EDAC_AMD64_ERROR_INJECTION is not set
CONFIG_EDAC_E752X=m
CONFIG_EDAC_I82975X=m
CONFIG_EDAC_I3000=m
CONFIG_EDAC_I3200=m
# CONFIG_EDAC_IE31200 is not set
CONFIG_EDAC_X38=m
CONFIG_EDAC_I5400=m
CONFIG_EDAC_I7CORE=m
CONFIG_EDAC_I5000=m
CONFIG_EDAC_I5100=m
CONFIG_EDAC_I7300=m
CONFIG_EDAC_SBRIDGE=m
# CONFIG_EDAC_SKX is not set
# CONFIG_EDAC_PND2 is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_MC146818_LIB=y
CONFIG_RTC_CLASS=y
CONFIG_RTC_HCTOSYS=y
CONFIG_RTC_HCTOSYS_DEVICE="rtc0"
# CONFIG_RTC_SYSTOHC is not set
# CONFIG_RTC_DEBUG is not set

#
# RTC interfaces
#
CONFIG_RTC_INTF_SYSFS=y
CONFIG_RTC_INTF_PROC=y
CONFIG_RTC_INTF_DEV=y
# CONFIG_RTC_INTF_DEV_UIE_EMUL is not set
# CONFIG_RTC_DRV_TEST is not set

#
# I2C RTC drivers
#
# CONFIG_RTC_DRV_ABB5ZES3 is not set
# CONFIG_RTC_DRV_ABX80X is not set
CONFIG_RTC_DRV_DS1307=m
CONFIG_RTC_DRV_DS1307_HWMON=y
# CONFIG_RTC_DRV_DS1307_CENTURY is not set
CONFIG_RTC_DRV_DS1374=m
# CONFIG_RTC_DRV_DS1374_WDT is not set
CONFIG_RTC_DRV_DS1672=m
CONFIG_RTC_DRV_MAX6900=m
CONFIG_RTC_DRV_RS5C372=m
CONFIG_RTC_DRV_ISL1208=m
CONFIG_RTC_DRV_ISL12022=m
CONFIG_RTC_DRV_X1205=m
CONFIG_RTC_DRV_PCF8523=m
# CONFIG_RTC_DRV_PCF85063 is not set
CONFIG_RTC_DRV_PCF8563=m
CONFIG_RTC_DRV_PCF8583=m
CONFIG_RTC_DRV_M41T80=m
CONFIG_RTC_DRV_M41T80_WDT=y
CONFIG_RTC_DRV_BQ32K=m
# CONFIG_RTC_DRV_S35390A is not set
CONFIG_RTC_DRV_FM3130=m
# CONFIG_RTC_DRV_RX8010 is not set
CONFIG_RTC_DRV_RX8581=m
CONFIG_RTC_DRV_RX8025=m
CONFIG_RTC_DRV_EM3027=m
# CONFIG_RTC_DRV_RV8803 is not set

#
# SPI RTC drivers
#
# CONFIG_RTC_DRV_M41T93 is not set
# CONFIG_RTC_DRV_M41T94 is not set
# CONFIG_RTC_DRV_DS1302 is not set
# CONFIG_RTC_DRV_DS1305 is not set
# CONFIG_RTC_DRV_DS1343 is not set
# CONFIG_RTC_DRV_DS1347 is not set
# CONFIG_RTC_DRV_DS1390 is not set
# CONFIG_RTC_DRV_MAX6916 is not set
# CONFIG_RTC_DRV_R9701 is not set
# CONFIG_RTC_DRV_RX4581 is not set
# CONFIG_RTC_DRV_RX6110 is not set
# CONFIG_RTC_DRV_RS5C348 is not set
# CONFIG_RTC_DRV_MAX6902 is not set
# CONFIG_RTC_DRV_PCF2123 is not set
# CONFIG_RTC_DRV_MCP795 is not set
CONFIG_RTC_I2C_AND_SPI=y

#
# SPI and I2C RTC drivers
#
CONFIG_RTC_DRV_DS3232=m
# CONFIG_RTC_DRV_PCF2127 is not set
CONFIG_RTC_DRV_RV3029C2=m
CONFIG_RTC_DRV_RV3029_HWMON=y

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=y
CONFIG_RTC_DRV_DS1286=m
CONFIG_RTC_DRV_DS1511=m
CONFIG_RTC_DRV_DS1553=m
# CONFIG_RTC_DRV_DS1685_FAMILY is not set
CONFIG_RTC_DRV_DS1742=m
CONFIG_RTC_DRV_DS2404=m
CONFIG_RTC_DRV_STK17TA8=m
# CONFIG_RTC_DRV_M48T86 is not set
CONFIG_RTC_DRV_M48T35=m
CONFIG_RTC_DRV_M48T59=m
CONFIG_RTC_DRV_MSM6242=m
CONFIG_RTC_DRV_BQ4802=m
CONFIG_RTC_DRV_RP5C01=m
CONFIG_RTC_DRV_V3020=m

#
# on-CPU RTC drivers
#

#
# HID Sensor RTC drivers
#
# CONFIG_RTC_DRV_HID_SENSOR_TIME is not set
CONFIG_DMADEVICES=y
# CONFIG_DMADEVICES_DEBUG is not set

#
# DMA Devices
#
CONFIG_DMA_ENGINE=y
CONFIG_DMA_VIRTUAL_CHANNELS=y
CONFIG_DMA_ACPI=y
# CONFIG_INTEL_IDMA64 is not set
# CONFIG_INTEL_IOATDMA is not set
# CONFIG_QCOM_HIDMA_MGMT is not set
# CONFIG_QCOM_HIDMA is not set
CONFIG_DW_DMAC_CORE=y
CONFIG_DW_DMAC=m
CONFIG_DW_DMAC_PCI=y
CONFIG_HSU_DMA=y

#
# DMA Clients
#
CONFIG_ASYNC_TX_DMA=y
CONFIG_DMATEST=m

#
# DMABUF options
#
CONFIG_SYNC_FILE=y
CONFIG_SW_SYNC=y
CONFIG_AUXDISPLAY=y
CONFIG_KS0108=m
CONFIG_KS0108_PORT=0x378
CONFIG_KS0108_DELAY=2
CONFIG_CFAG12864B=m
CONFIG_CFAG12864B_RATE=20
# CONFIG_IMG_ASCII_LCD is not set
CONFIG_UIO=m
CONFIG_UIO_CIF=m
CONFIG_UIO_PDRV_GENIRQ=m
# CONFIG_UIO_DMEM_GENIRQ is not set
CONFIG_UIO_AEC=m
CONFIG_UIO_SERCOS3=m
CONFIG_UIO_PCI_GENERIC=m
# CONFIG_UIO_NETX is not set
# CONFIG_UIO_PRUSS is not set
# CONFIG_UIO_MF624 is not set
# CONFIG_UIO_HV_GENERIC is not set
CONFIG_VFIO_IOMMU_TYPE1=m
CONFIG_VFIO_VIRQFD=m
CONFIG_VFIO=m
# CONFIG_VFIO_NOIOMMU is not set
CONFIG_VFIO_PCI=m
# CONFIG_VFIO_PCI_VGA is not set
CONFIG_VFIO_PCI_MMAP=y
CONFIG_VFIO_PCI_INTX=y
CONFIG_VFIO_PCI_IGD=y
# CONFIG_VFIO_MDEV is not set
CONFIG_IRQ_BYPASS_MANAGER=m
# CONFIG_VIRT_DRIVERS is not set
CONFIG_VIRTIO=y

#
# Virtio drivers
#
CONFIG_VIRTIO_PCI=y
CONFIG_VIRTIO_PCI_LEGACY=y
CONFIG_VIRTIO_BALLOON=y
# CONFIG_VIRTIO_INPUT is not set
# CONFIG_VIRTIO_MMIO is not set

#
# Microsoft Hyper-V guest support
#
CONFIG_HYPERV=m
CONFIG_HYPERV_UTILS=m
CONFIG_HYPERV_BALLOON=m

#
# Xen driver support
#
CONFIG_XEN_BALLOON=y
# CONFIG_XEN_SELFBALLOONING is not set
# CONFIG_XEN_BALLOON_MEMORY_HOTPLUG is not set
CONFIG_XEN_SCRUB_PAGES=y
CONFIG_XEN_DEV_EVTCHN=m
CONFIG_XEN_BACKEND=y
CONFIG_XENFS=m
CONFIG_XEN_COMPAT_XENFS=y
CONFIG_XEN_SYS_HYPERVISOR=y
CONFIG_XEN_XENBUS_FRONTEND=y
# CONFIG_XEN_GNTDEV is not set
# CONFIG_XEN_GRANT_DEV_ALLOC is not set
CONFIG_SWIOTLB_XEN=y
CONFIG_XEN_TMEM=m
CONFIG_XEN_PCIDEV_BACKEND=m
# CONFIG_XEN_SCSI_BACKEND is not set
CONFIG_XEN_PRIVCMD=m
CONFIG_XEN_ACPI_PROCESSOR=m
# CONFIG_XEN_MCE_LOG is not set
CONFIG_XEN_HAVE_PVMMU=y
CONFIG_XEN_EFI=y
CONFIG_XEN_AUTO_XLATE=y
CONFIG_XEN_ACPI=y
CONFIG_XEN_SYMS=y
CONFIG_XEN_HAVE_VPMU=y
CONFIG_STAGING=y
# CONFIG_PRISM2_USB is not set
# CONFIG_COMEDI is not set
# CONFIG_RTL8192U is not set
CONFIG_RTLLIB=m
CONFIG_RTLLIB_CRYPTO_CCMP=m
CONFIG_RTLLIB_CRYPTO_TKIP=m
CONFIG_RTLLIB_CRYPTO_WEP=m
CONFIG_RTL8192E=m
CONFIG_R8712U=m
# CONFIG_R8188EU is not set
# CONFIG_RTS5208 is not set
# CONFIG_VT6655 is not set
# CONFIG_VT6656 is not set
# CONFIG_FB_SM750 is not set
# CONFIG_FB_XGI is not set

#
# Speakup console speech
#
# CONFIG_SPEAKUP is not set
# CONFIG_STAGING_MEDIA is not set

#
# Android
#
# CONFIG_LTE_GDM724X is not set
CONFIG_FIREWIRE_SERIAL=m
CONFIG_FWTTY_MAX_TOTAL_PORTS=64
CONFIG_FWTTY_MAX_CARD_PORTS=32
# CONFIG_LNET is not set
# CONFIG_DGNC is not set
# CONFIG_GS_FPGABOOT is not set
# CONFIG_CRYPTO_SKEIN is not set
# CONFIG_UNISYSSPAR is not set
# CONFIG_FB_TFT is not set
# CONFIG_WILC1000_SDIO is not set
# CONFIG_WILC1000_SPI is not set
# CONFIG_MOST is not set
# CONFIG_KS7010 is not set
# CONFIG_GREYBUS is not set
CONFIG_X86_PLATFORM_DEVICES=y
CONFIG_ACER_WMI=m
CONFIG_ACERHDF=m
# CONFIG_ALIENWARE_WMI is not set
CONFIG_ASUS_LAPTOP=m
# CONFIG_DELL_LAPTOP is not set
# CONFIG_DELL_WMI is not set
CONFIG_DELL_WMI_AIO=m
# CONFIG_DELL_SMO8800 is not set
# CONFIG_DELL_RBTN is not set
CONFIG_FUJITSU_LAPTOP=m
# CONFIG_FUJITSU_LAPTOP_DEBUG is not set
CONFIG_FUJITSU_TABLET=m
CONFIG_AMILO_RFKILL=m
CONFIG_HP_ACCEL=m
# CONFIG_HP_WIRELESS is not set
CONFIG_HP_WMI=m
CONFIG_MSI_LAPTOP=m
CONFIG_PANASONIC_LAPTOP=m
CONFIG_COMPAL_LAPTOP=m
CONFIG_SONY_LAPTOP=m
CONFIG_SONYPI_COMPAT=y
CONFIG_IDEAPAD_LAPTOP=m
# CONFIG_SURFACE3_WMI is not set
CONFIG_THINKPAD_ACPI=m
CONFIG_THINKPAD_ACPI_ALSA_SUPPORT=y
# CONFIG_THINKPAD_ACPI_DEBUGFACILITIES is not set
# CONFIG_THINKPAD_ACPI_DEBUG is not set
# CONFIG_THINKPAD_ACPI_UNSAFE_LEDS is not set
CONFIG_THINKPAD_ACPI_VIDEO=y
CONFIG_THINKPAD_ACPI_HOTKEY_POLL=y
CONFIG_SENSORS_HDAPS=m
# CONFIG_INTEL_MENLOW is not set
CONFIG_EEEPC_LAPTOP=m
CONFIG_ASUS_WMI=m
CONFIG_ASUS_NB_WMI=m
CONFIG_EEEPC_WMI=m
# CONFIG_ASUS_WIRELESS is not set
CONFIG_ACPI_WMI=m
CONFIG_MSI_WMI=m
CONFIG_TOPSTAR_LAPTOP=m
CONFIG_TOSHIBA_BT_RFKILL=m
# CONFIG_TOSHIBA_HAPS is not set
# CONFIG_TOSHIBA_WMI is not set
CONFIG_ACPI_CMPC=m
# CONFIG_INTEL_HID_EVENT is not set
# CONFIG_INTEL_VBTN is not set
CONFIG_INTEL_IPS=m
# CONFIG_INTEL_PMC_CORE is not set
# CONFIG_IBM_RTL is not set
CONFIG_SAMSUNG_LAPTOP=m
CONFIG_MXM_WMI=m
CONFIG_INTEL_OAKTRAIL=m
CONFIG_SAMSUNG_Q10=m
CONFIG_APPLE_GMUX=m
# CONFIG_INTEL_RST is not set
# CONFIG_INTEL_SMARTCONNECT is not set
CONFIG_PVPANIC=y
# CONFIG_INTEL_PMC_IPC is not set
# CONFIG_SURFACE_PRO3_BUTTON is not set
# CONFIG_INTEL_PUNIT_IPC is not set
# CONFIG_MLX_PLATFORM is not set
# CONFIG_MLX_CPLD_PLATFORM is not set
# CONFIG_INTEL_TURBO_MAX_3 is not set
# CONFIG_SILEAD_DMI is not set
CONFIG_PMC_ATOM=y
# CONFIG_CHROME_PLATFORMS is not set
CONFIG_CLKDEV_LOOKUP=y
CONFIG_HAVE_CLK_PREPARE=y
CONFIG_COMMON_CLK=y

#
# Common Clock Framework
#
# CONFIG_COMMON_CLK_SI5351 is not set
# CONFIG_COMMON_CLK_CDCE706 is not set
# CONFIG_COMMON_CLK_CS2000_CP is not set
# CONFIG_COMMON_CLK_NXP is not set
# CONFIG_COMMON_CLK_PWM is not set
# CONFIG_COMMON_CLK_PXA is not set
# CONFIG_COMMON_CLK_PIC32 is not set

#
# Hardware Spinlock drivers
#

#
# Clock Source drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
# CONFIG_ATMEL_PIT is not set
# CONFIG_SH_TIMER_CMT is not set
# CONFIG_SH_TIMER_MTU2 is not set
# CONFIG_SH_TIMER_TMU is not set
# CONFIG_EM_TIMER_STI is not set
CONFIG_MAILBOX=y
CONFIG_PCC=y
# CONFIG_ALTERA_MBOX is not set
CONFIG_IOMMU_API=y
CONFIG_IOMMU_SUPPORT=y

#
# Generic IOMMU Pagetable Support
#
CONFIG_IOMMU_IOVA=y
CONFIG_AMD_IOMMU=y
CONFIG_AMD_IOMMU_V2=m
CONFIG_DMAR_TABLE=y
CONFIG_INTEL_IOMMU=y
# CONFIG_INTEL_IOMMU_SVM is not set
# CONFIG_INTEL_IOMMU_DEFAULT_ON is not set
CONFIG_INTEL_IOMMU_FLOPPY_WA=y
CONFIG_IRQ_REMAP=y

#
# Remoteproc drivers
#
# CONFIG_REMOTEPROC is not set

#
# Rpmsg drivers
#

#
# SOC (System On Chip) specific Drivers
#

#
# Broadcom SoC drivers
#
# CONFIG_SUNXI_SRAM is not set
# CONFIG_SOC_TI is not set
# CONFIG_SOC_ZTE is not set
CONFIG_PM_DEVFREQ=y

#
# DEVFREQ Governors
#
CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND=m
# CONFIG_DEVFREQ_GOV_PERFORMANCE is not set
# CONFIG_DEVFREQ_GOV_POWERSAVE is not set
# CONFIG_DEVFREQ_GOV_USERSPACE is not set
# CONFIG_DEVFREQ_GOV_PASSIVE is not set

#
# DEVFREQ Drivers
#
# CONFIG_PM_DEVFREQ_EVENT is not set
# CONFIG_EXTCON is not set
# CONFIG_MEMORY is not set
# CONFIG_IIO is not set
CONFIG_NTB=m
# CONFIG_NTB_AMD is not set
# CONFIG_NTB_INTEL is not set
# CONFIG_NTB_PINGPONG is not set
# CONFIG_NTB_TOOL is not set
# CONFIG_NTB_PERF is not set
# CONFIG_NTB_TRANSPORT is not set
# CONFIG_VME_BUS is not set
CONFIG_PWM=y
CONFIG_PWM_SYSFS=y
# CONFIG_PWM_LPSS_PCI is not set
# CONFIG_PWM_LPSS_PLATFORM is not set
# CONFIG_PWM_PCA9685 is not set
CONFIG_ARM_GIC_MAX_NR=1
# CONFIG_IPACK_BUS is not set
# CONFIG_RESET_CONTROLLER is not set
# CONFIG_FMC is not set

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
# CONFIG_PHY_PXA_28NM_HSIC is not set
# CONFIG_PHY_PXA_28NM_USB2 is not set
# CONFIG_BCM_KONA_USB2_PHY is not set
CONFIG_POWERCAP=y
CONFIG_INTEL_RAPL=m
# CONFIG_MCB is not set

#
# Performance monitor support
#
CONFIG_RAS=y
# CONFIG_MCE_AMD_INJ is not set
# CONFIG_THUNDERBOLT is not set

#
# Android
#
# CONFIG_ANDROID is not set
CONFIG_LIBNVDIMM=m
CONFIG_BLK_DEV_PMEM=m
CONFIG_ND_BLK=m
CONFIG_ND_CLAIM=y
CONFIG_ND_BTT=m
CONFIG_BTT=y
CONFIG_ND_PFN=m
CONFIG_NVDIMM_PFN=y
CONFIG_NVDIMM_DAX=y
CONFIG_DEV_DAX=m
CONFIG_DEV_DAX_PMEM=m
CONFIG_NR_DEV_DAX=32768
CONFIG_NVMEM=m
# CONFIG_STM is not set
# CONFIG_INTEL_TH is not set

#
# FPGA Configuration Support
#
# CONFIG_FPGA is not set

#
# FSI support
#
# CONFIG_FSI is not set

#
# Firmware Drivers
#
CONFIG_EDD=m
# CONFIG_EDD_OFF is not set
CONFIG_FIRMWARE_MEMMAP=y
CONFIG_DELL_RBU=m
CONFIG_DCDBAS=m
CONFIG_DMIID=y
CONFIG_DMI_SYSFS=y
CONFIG_DMI_SCAN_MACHINE_NON_EFI_FALLBACK=y
CONFIG_ISCSI_IBFT_FIND=y
CONFIG_ISCSI_IBFT=m
# CONFIG_FW_CFG_SYSFS is not set
# CONFIG_GOOGLE_FIRMWARE is not set

#
# EFI (Extensible Firmware Interface) Support
#
CONFIG_EFI_VARS=y
CONFIG_EFI_ESRT=y
CONFIG_EFI_VARS_PSTORE=y
CONFIG_EFI_VARS_PSTORE_DEFAULT_DISABLE=y
CONFIG_EFI_RUNTIME_MAP=y
# CONFIG_EFI_FAKE_MEMMAP is not set
CONFIG_EFI_RUNTIME_WRAPPERS=y
# CONFIG_EFI_BOOTLOADER_CONTROL is not set
# CONFIG_EFI_CAPSULE_LOADER is not set
# CONFIG_EFI_TEST is not set
# CONFIG_APPLE_PROPERTIES is not set
CONFIG_UEFI_CPER=y
# CONFIG_EFI_DEV_PATH_PARSER is not set

#
# Tegra firmware driver
#

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_FS_IOMAP=y
# CONFIG_EXT2_FS is not set
# CONFIG_EXT3_FS is not set
CONFIG_EXT4_FS=y
CONFIG_EXT4_USE_FOR_EXT2=y
CONFIG_EXT4_FS_POSIX_ACL=y
CONFIG_EXT4_FS_SECURITY=y
# CONFIG_EXT4_ENCRYPTION is not set
# CONFIG_EXT4_DEBUG is not set
CONFIG_JBD2=y
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=y
# CONFIG_REISERFS_FS is not set
# CONFIG_JFS_FS is not set
CONFIG_XFS_FS=y
CONFIG_XFS_QUOTA=y
CONFIG_XFS_POSIX_ACL=y
# CONFIG_XFS_RT is not set
# CONFIG_XFS_WARN is not set
# CONFIG_XFS_DEBUG is not set
CONFIG_GFS2_FS=m
CONFIG_GFS2_FS_LOCKING_DLM=y
CONFIG_OCFS2_FS=m
CONFIG_OCFS2_FS_O2CB=m
CONFIG_OCFS2_FS_USERSPACE_CLUSTER=m
CONFIG_OCFS2_FS_STATS=y
CONFIG_OCFS2_DEBUG_MASKLOG=y
# CONFIG_OCFS2_DEBUG_FS is not set
CONFIG_BTRFS_FS=m
CONFIG_BTRFS_FS_POSIX_ACL=y
# CONFIG_BTRFS_FS_CHECK_INTEGRITY is not set
# CONFIG_BTRFS_FS_RUN_SANITY_TESTS is not set
# CONFIG_BTRFS_DEBUG is not set
# CONFIG_BTRFS_ASSERT is not set
# CONFIG_NILFS2_FS is not set
CONFIG_F2FS_FS=m
CONFIG_F2FS_STAT_FS=y
CONFIG_F2FS_FS_XATTR=y
CONFIG_F2FS_FS_POSIX_ACL=y
# CONFIG_F2FS_FS_SECURITY is not set
# CONFIG_F2FS_CHECK_FS is not set
# CONFIG_F2FS_FS_ENCRYPTION is not set
# CONFIG_F2FS_IO_TRACE is not set
# CONFIG_F2FS_FAULT_INJECTION is not set
CONFIG_FS_DAX=y
CONFIG_FS_DAX_PMD=y
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
# CONFIG_EXPORTFS_BLOCK_OPS is not set
CONFIG_FILE_LOCKING=y
CONFIG_MANDATORY_FILE_LOCKING=y
# CONFIG_FS_ENCRYPTION is not set
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
CONFIG_FANOTIFY=y
CONFIG_FANOTIFY_ACCESS_PERMISSIONS=y
CONFIG_QUOTA=y
CONFIG_QUOTA_NETLINK_INTERFACE=y
CONFIG_PRINT_QUOTA_WARNING=y
# CONFIG_QUOTA_DEBUG is not set
CONFIG_QUOTA_TREE=y
# CONFIG_QFMT_V1 is not set
CONFIG_QFMT_V2=y
CONFIG_QUOTACTL=y
CONFIG_QUOTACTL_COMPAT=y
CONFIG_AUTOFS4_FS=y
CONFIG_FUSE_FS=m
CONFIG_CUSE=m
CONFIG_OVERLAY_FS=m
# CONFIG_OVERLAY_FS_REDIRECT_DIR is not set

#
# Caches
#
CONFIG_FSCACHE=m
CONFIG_FSCACHE_STATS=y
# CONFIG_FSCACHE_HISTOGRAM is not set
# CONFIG_FSCACHE_DEBUG is not set
# CONFIG_FSCACHE_OBJECT_LIST is not set
CONFIG_CACHEFILES=m
# CONFIG_CACHEFILES_DEBUG is not set
# CONFIG_CACHEFILES_HISTOGRAM is not set

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=m
CONFIG_JOLIET=y
CONFIG_ZISOFS=y
CONFIG_UDF_FS=m
CONFIG_UDF_NLS=y

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=m
CONFIG_MSDOS_FS=m
CONFIG_VFAT_FS=m
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="ascii"
# CONFIG_FAT_DEFAULT_UTF8 is not set
# CONFIG_NTFS_FS is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
CONFIG_PROC_VMCORE=y
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_PROC_CHILDREN=y
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_TMPFS_XATTR=y
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_ARCH_HAS_GIGANTIC_PAGE=y
CONFIG_CONFIGFS_FS=y
CONFIG_EFIVAR_FS=y
CONFIG_MISC_FILESYSTEMS=y
# CONFIG_ORANGEFS_FS is not set
# CONFIG_ADFS_FS is not set
# CONFIG_AFFS_FS is not set
# CONFIG_ECRYPT_FS is not set
# CONFIG_HFS_FS is not set
# CONFIG_HFSPLUS_FS is not set
# CONFIG_BEFS_FS is not set
# CONFIG_BFS_FS is not set
# CONFIG_EFS_FS is not set
# CONFIG_JFFS2_FS is not set
# CONFIG_UBIFS_FS is not set
CONFIG_CRAMFS=m
CONFIG_SQUASHFS=m
CONFIG_SQUASHFS_FILE_CACHE=y
# CONFIG_SQUASHFS_FILE_DIRECT is not set
CONFIG_SQUASHFS_DECOMP_SINGLE=y
# CONFIG_SQUASHFS_DECOMP_MULTI is not set
# CONFIG_SQUASHFS_DECOMP_MULTI_PERCPU is not set
CONFIG_SQUASHFS_XATTR=y
CONFIG_SQUASHFS_ZLIB=y
# CONFIG_SQUASHFS_LZ4 is not set
CONFIG_SQUASHFS_LZO=y
CONFIG_SQUASHFS_XZ=y
# CONFIG_SQUASHFS_4K_DEVBLK_SIZE is not set
# CONFIG_SQUASHFS_EMBEDDED is not set
CONFIG_SQUASHFS_FRAGMENT_CACHE_SIZE=3
# CONFIG_VXFS_FS is not set
# CONFIG_MINIX_FS is not set
# CONFIG_OMFS_FS is not set
# CONFIG_HPFS_FS is not set
# CONFIG_QNX4FS_FS is not set
# CONFIG_QNX6FS_FS is not set
# CONFIG_ROMFS_FS is not set
CONFIG_PSTORE=y
CONFIG_PSTORE_ZLIB_COMPRESS=y
# CONFIG_PSTORE_LZO_COMPRESS is not set
# CONFIG_PSTORE_LZ4_COMPRESS is not set
CONFIG_PSTORE_CONSOLE=y
CONFIG_PSTORE_PMSG=y
# CONFIG_PSTORE_FTRACE is not set
CONFIG_PSTORE_RAM=m
# CONFIG_SYSV_FS is not set
# CONFIG_UFS_FS is not set
# CONFIG_EXOFS_FS is not set
CONFIG_ORE=m
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=y
# CONFIG_NFS_V2 is not set
CONFIG_NFS_V3=y
CONFIG_NFS_V3_ACL=y
CONFIG_NFS_V4=m
# CONFIG_NFS_SWAP is not set
CONFIG_NFS_V4_1=y
CONFIG_NFS_V4_2=y
CONFIG_PNFS_FILE_LAYOUT=m
CONFIG_PNFS_BLOCK=m
CONFIG_PNFS_OBJLAYOUT=m
CONFIG_PNFS_FLEXFILE_LAYOUT=m
CONFIG_NFS_V4_1_IMPLEMENTATION_ID_DOMAIN="kernel.org"
# CONFIG_NFS_V4_1_MIGRATION is not set
CONFIG_NFS_V4_SECURITY_LABEL=y
CONFIG_ROOT_NFS=y
# CONFIG_NFS_USE_LEGACY_DNS is not set
CONFIG_NFS_USE_KERNEL_DNS=y
CONFIG_NFS_DEBUG=y
CONFIG_NFSD=m
CONFIG_NFSD_V2_ACL=y
CONFIG_NFSD_V3=y
CONFIG_NFSD_V3_ACL=y
CONFIG_NFSD_V4=y
# CONFIG_NFSD_BLOCKLAYOUT is not set
# CONFIG_NFSD_SCSILAYOUT is not set
# CONFIG_NFSD_FLEXFILELAYOUT is not set
CONFIG_NFSD_V4_SECURITY_LABEL=y
# CONFIG_NFSD_FAULT_INJECTION is not set
CONFIG_GRACE_PERIOD=y
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_NFS_ACL_SUPPORT=y
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=y
CONFIG_SUNRPC_GSS=m
CONFIG_SUNRPC_BACKCHANNEL=y
CONFIG_RPCSEC_GSS_KRB5=m
CONFIG_SUNRPC_DEBUG=y
# CONFIG_CEPH_FS is not set
CONFIG_CIFS=m
CONFIG_CIFS_STATS=y
# CONFIG_CIFS_STATS2 is not set
CONFIG_CIFS_WEAK_PW_HASH=y
CONFIG_CIFS_UPCALL=y
CONFIG_CIFS_XATTR=y
CONFIG_CIFS_POSIX=y
CONFIG_CIFS_ACL=y
CONFIG_CIFS_DEBUG=y
# CONFIG_CIFS_DEBUG2 is not set
CONFIG_CIFS_DFS_UPCALL=y
CONFIG_CIFS_SMB2=y
# CONFIG_CIFS_SMB311 is not set
# CONFIG_CIFS_FSCACHE is not set
# CONFIG_NCP_FS is not set
# CONFIG_CODA_FS is not set
# CONFIG_AFS_FS is not set
CONFIG_9P_FS=y
CONFIG_9P_FS_POSIX_ACL=y
# CONFIG_9P_FS_SECURITY is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="utf8"
CONFIG_NLS_CODEPAGE_437=y
CONFIG_NLS_CODEPAGE_737=m
CONFIG_NLS_CODEPAGE_775=m
CONFIG_NLS_CODEPAGE_850=m
CONFIG_NLS_CODEPAGE_852=m
CONFIG_NLS_CODEPAGE_855=m
CONFIG_NLS_CODEPAGE_857=m
CONFIG_NLS_CODEPAGE_860=m
CONFIG_NLS_CODEPAGE_861=m
CONFIG_NLS_CODEPAGE_862=m
CONFIG_NLS_CODEPAGE_863=m
CONFIG_NLS_CODEPAGE_864=m
CONFIG_NLS_CODEPAGE_865=m
CONFIG_NLS_CODEPAGE_866=m
CONFIG_NLS_CODEPAGE_869=m
CONFIG_NLS_CODEPAGE_936=m
CONFIG_NLS_CODEPAGE_950=m
CONFIG_NLS_CODEPAGE_932=m
CONFIG_NLS_CODEPAGE_949=m
CONFIG_NLS_CODEPAGE_874=m
CONFIG_NLS_ISO8859_8=m
CONFIG_NLS_CODEPAGE_1250=m
CONFIG_NLS_CODEPAGE_1251=m
CONFIG_NLS_ASCII=y
CONFIG_NLS_ISO8859_1=m
CONFIG_NLS_ISO8859_2=m
CONFIG_NLS_ISO8859_3=m
CONFIG_NLS_ISO8859_4=m
CONFIG_NLS_ISO8859_5=m
CONFIG_NLS_ISO8859_6=m
CONFIG_NLS_ISO8859_7=m
CONFIG_NLS_ISO8859_9=m
CONFIG_NLS_ISO8859_13=m
CONFIG_NLS_ISO8859_14=m
CONFIG_NLS_ISO8859_15=m
CONFIG_NLS_KOI8_R=m
CONFIG_NLS_KOI8_U=m
CONFIG_NLS_MAC_ROMAN=m
CONFIG_NLS_MAC_CELTIC=m
CONFIG_NLS_MAC_CENTEURO=m
CONFIG_NLS_MAC_CROATIAN=m
CONFIG_NLS_MAC_CYRILLIC=m
CONFIG_NLS_MAC_GAELIC=m
CONFIG_NLS_MAC_GREEK=m
CONFIG_NLS_MAC_ICELAND=m
CONFIG_NLS_MAC_INUIT=m
CONFIG_NLS_MAC_ROMANIAN=m
CONFIG_NLS_MAC_TURKISH=m
CONFIG_NLS_UTF8=m
CONFIG_DLM=m
CONFIG_DLM_DEBUG=y

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
CONFIG_CONSOLE_LOGLEVEL_DEFAULT=7
CONFIG_MESSAGE_LOGLEVEL_DEFAULT=4
CONFIG_BOOT_PRINTK_DELAY=y
CONFIG_DYNAMIC_DEBUG=y

#
# Compile-time checks and compiler options
#
# CONFIG_DEBUG_INFO is not set
# CONFIG_ENABLE_WARN_DEPRECATED is not set
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=2048
CONFIG_STRIP_ASM_SYMS=y
# CONFIG_READABLE_ASM is not set
# CONFIG_UNUSED_SYMBOLS is not set
# CONFIG_PAGE_OWNER is not set
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
CONFIG_DEBUG_SECTION_MISMATCH=y
CONFIG_SECTION_MISMATCH_WARN_ONLY=y
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
# CONFIG_STACK_VALIDATION is not set
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
CONFIG_MAGIC_SYSRQ_SERIAL=y
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
# CONFIG_PAGE_EXTENSION is not set
# CONFIG_DEBUG_PAGEALLOC is not set
# CONFIG_PAGE_POISONING is not set
# CONFIG_DEBUG_PAGE_REF is not set
CONFIG_DEBUG_RODATA_TEST=y
# CONFIG_DEBUG_OBJECTS is not set
# CONFIG_SLUB_DEBUG_ON is not set
# CONFIG_SLUB_STATS is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
# CONFIG_DEBUG_STACK_USAGE is not set
# CONFIG_DEBUG_VM is not set
CONFIG_ARCH_HAS_DEBUG_VIRTUAL=y
# CONFIG_DEBUG_VIRTUAL is not set
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_MEMORY_NOTIFIER_ERROR_INJECT=m
# CONFIG_DEBUG_PER_CPU_MAPS is not set
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
CONFIG_DEBUG_STACKOVERFLOW=y
CONFIG_HAVE_ARCH_KMEMCHECK=y
CONFIG_HAVE_ARCH_KASAN=y
# CONFIG_KASAN is not set
CONFIG_ARCH_HAS_KCOV=y
# CONFIG_KCOV is not set
CONFIG_DEBUG_SHIRQ=y

#
# Debug Lockups and Hangs
#
CONFIG_LOCKUP_DETECTOR=y
CONFIG_HARDLOCKUP_DETECTOR=y
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC=y
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC_VALUE=1
# CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=0
# CONFIG_DETECT_HUNG_TASK is not set
# CONFIG_WQ_WATCHDOG is not set
CONFIG_PANIC_ON_OOPS=y
CONFIG_PANIC_ON_OOPS_VALUE=1
CONFIG_PANIC_TIMEOUT=0
CONFIG_SCHED_DEBUG=y
CONFIG_SCHED_INFO=y
CONFIG_SCHEDSTATS=y
# CONFIG_SCHED_STACK_END_CHECK is not set
# CONFIG_DEBUG_TIMEKEEPING is not set

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
# CONFIG_DEBUG_RT_MUTEXES is not set
# CONFIG_DEBUG_SPINLOCK is not set
# CONFIG_DEBUG_MUTEXES is not set
# CONFIG_DEBUG_WW_MUTEX_SLOWPATH is not set
# CONFIG_DEBUG_LOCK_ALLOC is not set
# CONFIG_PROVE_LOCKING is not set
# CONFIG_LOCK_STAT is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
CONFIG_LOCK_TORTURE_TEST=m
# CONFIG_WW_MUTEX_SELFTEST is not set
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_LIST=y
# CONFIG_DEBUG_PI_LIST is not set
# CONFIG_DEBUG_SG is not set
# CONFIG_DEBUG_NOTIFIERS is not set
# CONFIG_DEBUG_CREDENTIALS is not set

#
# RCU Debugging
#
# CONFIG_PROVE_RCU is not set
CONFIG_SPARSE_RCU_POINTER=y
CONFIG_TORTURE_TEST=m
# CONFIG_RCU_PERF_TEST is not set
CONFIG_RCU_TORTURE_TEST=m
# CONFIG_RCU_TORTURE_TEST_SLOW_PREINIT is not set
# CONFIG_RCU_TORTURE_TEST_SLOW_INIT is not set
# CONFIG_RCU_TORTURE_TEST_SLOW_CLEANUP is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=60
# CONFIG_RCU_TRACE is not set
# CONFIG_RCU_EQS_DEBUG is not set
# CONFIG_DEBUG_WQ_FORCE_RR_CPU is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_CPU_HOTPLUG_STATE_CONTROL is not set
CONFIG_NOTIFIER_ERROR_INJECTION=m
CONFIG_PM_NOTIFIER_ERROR_INJECT=m
# CONFIG_NETDEV_NOTIFIER_ERROR_INJECT is not set
# CONFIG_FAULT_INJECTION is not set
CONFIG_LATENCYTOP=y
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_NOP_TRACER=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_FENTRY=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACER_MAX_TRACE=y
CONFIG_TRACE_CLOCK=y
CONFIG_RING_BUFFER=y
CONFIG_EVENT_TRACING=y
CONFIG_CONTEXT_SWITCH_TRACER=y
CONFIG_RING_BUFFER_ALLOW_SWAP=y
CONFIG_TRACING=y
CONFIG_GENERIC_TRACER=y
CONFIG_TRACING_SUPPORT=y
CONFIG_FTRACE=y
CONFIG_FUNCTION_TRACER=y
CONFIG_FUNCTION_GRAPH_TRACER=y
# CONFIG_IRQSOFF_TRACER is not set
CONFIG_SCHED_TRACER=y
# CONFIG_HWLAT_TRACER is not set
CONFIG_FTRACE_SYSCALLS=y
CONFIG_TRACER_SNAPSHOT=y
# CONFIG_TRACER_SNAPSHOT_PER_CPU_SWAP is not set
CONFIG_BRANCH_PROFILE_NONE=y
# CONFIG_PROFILE_ANNOTATED_BRANCHES is not set
# CONFIG_PROFILE_ALL_BRANCHES is not set
CONFIG_STACK_TRACER=y
CONFIG_BLK_DEV_IO_TRACE=y
CONFIG_KPROBE_EVENTS=y
# CONFIG_UPROBE_EVENTS is not set
CONFIG_BPF_EVENTS=y
CONFIG_PROBE_EVENTS=y
CONFIG_DYNAMIC_FTRACE=y
CONFIG_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_FUNCTION_PROFILER=y
CONFIG_FTRACE_MCOUNT_RECORD=y
# CONFIG_FTRACE_STARTUP_TEST is not set
# CONFIG_MMIOTRACE is not set
CONFIG_TRACING_MAP=y
CONFIG_HIST_TRIGGERS=y
# CONFIG_TRACEPOINT_BENCHMARK is not set
CONFIG_RING_BUFFER_BENCHMARK=m
# CONFIG_RING_BUFFER_STARTUP_TEST is not set
# CONFIG_TRACE_ENUM_MAP_FILE is not set
CONFIG_TRACING_EVENTS_GPIO=y

#
# Runtime Testing
#
CONFIG_LKDTM=m
# CONFIG_TEST_LIST_SORT is not set
# CONFIG_TEST_SORT is not set
# CONFIG_KPROBES_SANITY_TEST is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
CONFIG_RBTREE_TEST=m
CONFIG_INTERVAL_TREE_TEST=m
CONFIG_PERCPU_TEST=m
CONFIG_ATOMIC64_SELFTEST=y
CONFIG_ASYNC_RAID6_TEST=m
# CONFIG_TEST_HEXDUMP is not set
# CONFIG_TEST_STRING_HELPERS is not set
CONFIG_TEST_KSTRTOX=m
CONFIG_TEST_PRINTF=m
CONFIG_TEST_BITMAP=m
# CONFIG_TEST_UUID is not set
# CONFIG_TEST_RHASHTABLE is not set
# CONFIG_TEST_HASH is not set
CONFIG_PROVIDE_OHCI1394_DMA_INIT=y
# CONFIG_DMA_API_DEBUG is not set
CONFIG_TEST_LKM=m
CONFIG_TEST_USER_COPY=m
CONFIG_TEST_BPF=m
CONFIG_TEST_FIRMWARE=m
CONFIG_TEST_UDELAY=m
# CONFIG_MEMTEST is not set
CONFIG_TEST_STATIC_KEYS=m
# CONFIG_BUG_ON_DATA_CORRUPTION is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_ARCH_HAS_UBSAN_SANITIZE_ALL=y
# CONFIG_ARCH_WANTS_UBSAN_NO_NULL is not set
# CONFIG_UBSAN is not set
CONFIG_ARCH_HAS_DEVMEM_IS_ALLOWED=y
CONFIG_STRICT_DEVMEM=y
# CONFIG_IO_STRICT_DEVMEM is not set
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
CONFIG_EARLY_PRINTK_DBGP=y
# CONFIG_EARLY_PRINTK_EFI is not set
# CONFIG_X86_PTDUMP_CORE is not set
# CONFIG_X86_PTDUMP is not set
# CONFIG_EFI_PGT_DUMP is not set
# CONFIG_DEBUG_WX is not set
CONFIG_DOUBLEFAULT=y
# CONFIG_DEBUG_TLBFLUSH is not set
# CONFIG_IOMMU_DEBUG is not set
# CONFIG_IOMMU_STRESS is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_X86_DECODER_SELFTEST=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
CONFIG_IO_DELAY_0X80=y
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=0
CONFIG_DEBUG_BOOT_PARAMS=y
# CONFIG_CPA_DEBUG is not set
CONFIG_OPTIMIZE_INLINING=y
# CONFIG_DEBUG_ENTRY is not set
# CONFIG_DEBUG_NMI_SELFTEST is not set
CONFIG_X86_DEBUG_FPU=y
# CONFIG_PUNIT_ATOM_DEBUG is not set

#
# Security options
#
CONFIG_KEYS=y
CONFIG_PERSISTENT_KEYRINGS=y
CONFIG_BIG_KEYS=y
CONFIG_TRUSTED_KEYS=y
CONFIG_ENCRYPTED_KEYS=y
# CONFIG_KEY_DH_OPERATIONS is not set
# CONFIG_SECURITY_DMESG_RESTRICT is not set
CONFIG_SECURITY=y
CONFIG_SECURITYFS=y
CONFIG_SECURITY_NETWORK=y
CONFIG_SECURITY_NETWORK_XFRM=y
# CONFIG_SECURITY_PATH is not set
CONFIG_INTEL_TXT=y
CONFIG_LSM_MMAP_MIN_ADDR=65535
CONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR=y
CONFIG_HAVE_ARCH_HARDENED_USERCOPY=y
# CONFIG_HARDENED_USERCOPY is not set
# CONFIG_STATIC_USERMODEHELPER is not set
CONFIG_SECURITY_SELINUX=y
CONFIG_SECURITY_SELINUX_BOOTPARAM=y
CONFIG_SECURITY_SELINUX_BOOTPARAM_VALUE=1
CONFIG_SECURITY_SELINUX_DISABLE=y
CONFIG_SECURITY_SELINUX_DEVELOP=y
CONFIG_SECURITY_SELINUX_AVC_STATS=y
CONFIG_SECURITY_SELINUX_CHECKREQPROT_VALUE=1
# CONFIG_SECURITY_SMACK is not set
# CONFIG_SECURITY_TOMOYO is not set
# CONFIG_SECURITY_APPARMOR is not set
# CONFIG_SECURITY_LOADPIN is not set
# CONFIG_SECURITY_YAMA is not set
CONFIG_INTEGRITY=y
CONFIG_INTEGRITY_SIGNATURE=y
CONFIG_INTEGRITY_ASYMMETRIC_KEYS=y
CONFIG_INTEGRITY_TRUSTED_KEYRING=y
CONFIG_INTEGRITY_AUDIT=y
CONFIG_IMA=y
CONFIG_IMA_MEASURE_PCR_IDX=10
CONFIG_IMA_LSM_RULES=y
# CONFIG_IMA_TEMPLATE is not set
CONFIG_IMA_NG_TEMPLATE=y
# CONFIG_IMA_SIG_TEMPLATE is not set
CONFIG_IMA_DEFAULT_TEMPLATE="ima-ng"
CONFIG_IMA_DEFAULT_HASH_SHA1=y
# CONFIG_IMA_DEFAULT_HASH_SHA256 is not set
# CONFIG_IMA_DEFAULT_HASH_SHA512 is not set
# CONFIG_IMA_DEFAULT_HASH_WP512 is not set
CONFIG_IMA_DEFAULT_HASH="sha1"
# CONFIG_IMA_WRITE_POLICY is not set
# CONFIG_IMA_READ_POLICY is not set
CONFIG_IMA_APPRAISE=y
CONFIG_IMA_TRUSTED_KEYRING=y
# CONFIG_IMA_BLACKLIST_KEYRING is not set
# CONFIG_IMA_LOAD_X509 is not set
CONFIG_EVM=y
CONFIG_EVM_ATTR_FSUUID=y
# CONFIG_EVM_LOAD_X509 is not set
CONFIG_DEFAULT_SECURITY_SELINUX=y
# CONFIG_DEFAULT_SECURITY_DAC is not set
CONFIG_DEFAULT_SECURITY="selinux"
CONFIG_XOR_BLOCKS=m
CONFIG_ASYNC_CORE=m
CONFIG_ASYNC_MEMCPY=m
CONFIG_ASYNC_XOR=m
CONFIG_ASYNC_PQ=m
CONFIG_ASYNC_RAID6_RECOV=m
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=y
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=y
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG=y
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_RNG_DEFAULT=y
CONFIG_CRYPTO_AKCIPHER2=y
CONFIG_CRYPTO_AKCIPHER=y
CONFIG_CRYPTO_KPP2=y
CONFIG_CRYPTO_ACOMP2=y
CONFIG_CRYPTO_RSA=y
# CONFIG_CRYPTO_DH is not set
# CONFIG_CRYPTO_ECDH is not set
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
CONFIG_CRYPTO_USER=m
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=m
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_NULL2=y
CONFIG_CRYPTO_PCRYPT=m
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=m
# CONFIG_CRYPTO_MCRYPTD is not set
CONFIG_CRYPTO_AUTHENC=m
CONFIG_CRYPTO_TEST=m
CONFIG_CRYPTO_ABLK_HELPER=m
CONFIG_CRYPTO_SIMD=m
CONFIG_CRYPTO_GLUE_HELPER_X86=m
CONFIG_CRYPTO_ENGINE=m

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=m
CONFIG_CRYPTO_GCM=m
# CONFIG_CRYPTO_CHACHA20POLY1305 is not set
CONFIG_CRYPTO_SEQIV=y
CONFIG_CRYPTO_ECHAINIV=m

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=m
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=m
CONFIG_CRYPTO_PCBC=m
CONFIG_CRYPTO_XTS=m
# CONFIG_CRYPTO_KEYWRAP is not set

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=m
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=m
CONFIG_CRYPTO_VMAC=m

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=m
CONFIG_CRYPTO_CRC32=m
CONFIG_CRYPTO_CRC32_PCLMUL=m
CONFIG_CRYPTO_CRCT10DIF=y
CONFIG_CRYPTO_CRCT10DIF_PCLMUL=m
CONFIG_CRYPTO_GHASH=m
# CONFIG_CRYPTO_POLY1305 is not set
# CONFIG_CRYPTO_POLY1305_X86_64 is not set
CONFIG_CRYPTO_MD4=m
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=m
CONFIG_CRYPTO_RMD128=m
CONFIG_CRYPTO_RMD160=m
CONFIG_CRYPTO_RMD256=m
CONFIG_CRYPTO_RMD320=m
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_SSSE3=m
CONFIG_CRYPTO_SHA256_SSSE3=m
CONFIG_CRYPTO_SHA512_SSSE3=m
# CONFIG_CRYPTO_SHA1_MB is not set
# CONFIG_CRYPTO_SHA256_MB is not set
# CONFIG_CRYPTO_SHA512_MB is not set
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=m
# CONFIG_CRYPTO_SHA3 is not set
CONFIG_CRYPTO_TGR192=m
CONFIG_CRYPTO_WP512=m
CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL=m

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
# CONFIG_CRYPTO_AES_TI is not set
CONFIG_CRYPTO_AES_X86_64=y
CONFIG_CRYPTO_AES_NI_INTEL=m
CONFIG_CRYPTO_ANUBIS=m
CONFIG_CRYPTO_ARC4=m
CONFIG_CRYPTO_BLOWFISH=m
CONFIG_CRYPTO_BLOWFISH_COMMON=m
CONFIG_CRYPTO_BLOWFISH_X86_64=m
CONFIG_CRYPTO_CAMELLIA=m
CONFIG_CRYPTO_CAMELLIA_X86_64=m
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64=m
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64=m
CONFIG_CRYPTO_CAST_COMMON=m
CONFIG_CRYPTO_CAST5=m
CONFIG_CRYPTO_CAST5_AVX_X86_64=m
CONFIG_CRYPTO_CAST6=m
CONFIG_CRYPTO_CAST6_AVX_X86_64=m
CONFIG_CRYPTO_DES=m
# CONFIG_CRYPTO_DES3_EDE_X86_64 is not set
CONFIG_CRYPTO_FCRYPT=m
CONFIG_CRYPTO_KHAZAD=m
CONFIG_CRYPTO_SALSA20=m
CONFIG_CRYPTO_SALSA20_X86_64=m
# CONFIG_CRYPTO_CHACHA20 is not set
# CONFIG_CRYPTO_CHACHA20_X86_64 is not set
CONFIG_CRYPTO_SEED=m
CONFIG_CRYPTO_SERPENT=m
CONFIG_CRYPTO_SERPENT_SSE2_X86_64=m
CONFIG_CRYPTO_SERPENT_AVX_X86_64=m
CONFIG_CRYPTO_SERPENT_AVX2_X86_64=m
CONFIG_CRYPTO_TEA=m
CONFIG_CRYPTO_TWOFISH=m
CONFIG_CRYPTO_TWOFISH_COMMON=m
CONFIG_CRYPTO_TWOFISH_X86_64=m
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=m
CONFIG_CRYPTO_TWOFISH_AVX_X86_64=m

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=m
CONFIG_CRYPTO_LZO=y
# CONFIG_CRYPTO_842 is not set
# CONFIG_CRYPTO_LZ4 is not set
# CONFIG_CRYPTO_LZ4HC is not set

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=m
CONFIG_CRYPTO_DRBG_MENU=y
CONFIG_CRYPTO_DRBG_HMAC=y
# CONFIG_CRYPTO_DRBG_HASH is not set
# CONFIG_CRYPTO_DRBG_CTR is not set
CONFIG_CRYPTO_DRBG=y
CONFIG_CRYPTO_JITTERENTROPY=y
CONFIG_CRYPTO_USER_API=y
CONFIG_CRYPTO_USER_API_HASH=y
CONFIG_CRYPTO_USER_API_SKCIPHER=y
# CONFIG_CRYPTO_USER_API_RNG is not set
# CONFIG_CRYPTO_USER_API_AEAD is not set
CONFIG_CRYPTO_HASH_INFO=y
CONFIG_CRYPTO_HW=y
CONFIG_CRYPTO_DEV_PADLOCK=m
CONFIG_CRYPTO_DEV_PADLOCK_AES=m
CONFIG_CRYPTO_DEV_PADLOCK_SHA=m
# CONFIG_CRYPTO_DEV_FSL_CAAM_CRYPTO_API_DESC is not set
# CONFIG_CRYPTO_DEV_CCP is not set
# CONFIG_CRYPTO_DEV_QAT_DH895xCC is not set
# CONFIG_CRYPTO_DEV_QAT_C3XXX is not set
# CONFIG_CRYPTO_DEV_QAT_C62X is not set
# CONFIG_CRYPTO_DEV_QAT_DH895xCCVF is not set
# CONFIG_CRYPTO_DEV_QAT_C3XXXVF is not set
# CONFIG_CRYPTO_DEV_QAT_C62XVF is not set
# CONFIG_CRYPTO_DEV_CHELSIO is not set
CONFIG_CRYPTO_DEV_VIRTIO=m
CONFIG_ASYMMETRIC_KEY_TYPE=y
CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=y
CONFIG_X509_CERTIFICATE_PARSER=y
# CONFIG_PKCS7_MESSAGE_PARSER is not set

#
# Certificates for signature checking
#
CONFIG_SYSTEM_TRUSTED_KEYRING=y
CONFIG_SYSTEM_TRUSTED_KEYS=""
# CONFIG_SYSTEM_EXTRA_CERTIFICATE is not set
# CONFIG_SECONDARY_TRUSTED_KEYRING is not set
CONFIG_HAVE_KVM=y
CONFIG_HAVE_KVM_IRQCHIP=y
CONFIG_HAVE_KVM_IRQFD=y
CONFIG_HAVE_KVM_IRQ_ROUTING=y
CONFIG_HAVE_KVM_EVENTFD=y
CONFIG_KVM_MMIO=y
CONFIG_KVM_ASYNC_PF=y
CONFIG_HAVE_KVM_MSI=y
CONFIG_HAVE_KVM_CPU_RELAX_INTERCEPT=y
CONFIG_KVM_VFIO=y
CONFIG_KVM_GENERIC_DIRTYLOG_READ_PROTECT=y
CONFIG_KVM_COMPAT=y
CONFIG_HAVE_KVM_IRQ_BYPASS=y
CONFIG_VIRTUALIZATION=y
CONFIG_KVM=m
CONFIG_KVM_INTEL=m
CONFIG_KVM_AMD=m
CONFIG_KVM_MMU_AUDIT=y
# CONFIG_KVM_DEVICE_ASSIGNMENT is not set
CONFIG_VHOST_NET=m
# CONFIG_VHOST_SCSI is not set
# CONFIG_VHOST_VSOCK is not set
CONFIG_VHOST=m
# CONFIG_VHOST_CROSS_ENDIAN_LEGACY is not set
CONFIG_BINARY_PRINTF=y

#
# Library routines
#
CONFIG_RAID6_PQ=m
CONFIG_BITREVERSE=y
# CONFIG_HAVE_ARCH_BITREVERSE is not set
CONFIG_RATIONAL=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_IO=y
CONFIG_ARCH_USE_CMPXCHG_LOCKREF=y
CONFIG_ARCH_HAS_FAST_MULTIPLIER=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=m
CONFIG_CRC32=y
# CONFIG_CRC32_SELFTEST is not set
CONFIG_CRC32_SLICEBY8=y
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
# CONFIG_CRC7 is not set
CONFIG_LIBCRC32C=y
CONFIG_CRC8=m
# CONFIG_AUDIT_ARCH_COMPAT_GENERIC is not set
# CONFIG_RANDOM32_SELFTEST is not set
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
CONFIG_XZ_DEC=y
CONFIG_XZ_DEC_X86=y
CONFIG_XZ_DEC_POWERPC=y
CONFIG_XZ_DEC_IA64=y
CONFIG_XZ_DEC_ARM=y
CONFIG_XZ_DEC_ARMTHUMB=y
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
# CONFIG_XZ_DEC_TEST is not set
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_DECOMPRESS_XZ=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_REED_SOLOMON=m
CONFIG_REED_SOLOMON_ENC8=y
CONFIG_REED_SOLOMON_DEC8=y
CONFIG_TEXTSEARCH=y
CONFIG_TEXTSEARCH_KMP=m
CONFIG_TEXTSEARCH_BM=m
CONFIG_TEXTSEARCH_FSM=m
CONFIG_BTREE=y
CONFIG_INTERVAL_TREE=y
CONFIG_RADIX_TREE_MULTIORDER=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
# CONFIG_DMA_NOOP_OPS is not set
# CONFIG_DMA_VIRT_OPS is not set
CONFIG_CHECK_SIGNATURE=y
CONFIG_CPUMASK_OFFSTACK=y
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_GLOB=y
# CONFIG_GLOB_SELFTEST is not set
CONFIG_NLATTR=y
CONFIG_CLZ_TAB=y
CONFIG_CORDIC=m
# CONFIG_DDR is not set
CONFIG_IRQ_POLL=y
CONFIG_MPILIB=y
CONFIG_SIGNATURE=y
CONFIG_OID_REGISTRY=y
CONFIG_UCS2_STRING=y
CONFIG_FONT_SUPPORT=y
# CONFIG_FONTS is not set
CONFIG_FONT_8x8=y
CONFIG_FONT_8x16=y
# CONFIG_SG_SPLIT is not set
CONFIG_SG_POOL=y
CONFIG_ARCH_HAS_SG_CHAIN=y
CONFIG_ARCH_HAS_PMEM_API=y
CONFIG_ARCH_HAS_MMIO_FLUSH=y
CONFIG_SBITMAP=y

--Q0rSlbzrZN6k9QnT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=job-script

#!/bin/sh

export_top_env()
{
	export suite='ltp'
	export testcase='ltp'
	export category='functional'
	export job_origin='/lkp/lkp/.src-20170430-103405/allot/cyclic:linux-devel:devel-hourly/nhm-white2/ltp.yaml'
	export queue='bisect'
	export testbox='nhm-white2'
	export tbox_group='nhm-white2'
	export submit_id='5907a8010b9a93884187f9f1'
	export job_file='/lkp/scheduled/nhm-white2/ltp-containers-debian-x86_64-2016-08-31.cgz-e445e46642deb36af94d8289f6351b122e6bd8f1-20170502-34881-1oevfbd-0.yaml'
	export id='dcbf87865b925e9dc7c7c2c75c107558a633fa19'
	export model='Nehalem'
	export memory='4G'
	export nr_cpu=8
	export hdd_partitions=
	export swap_partitions=
	export rootfs_partition=
	export netconsole_port=6671
	export brand='Intel(R) Core(TM) i7 CPU 870 @ 2.93GHz'
	export need_kconfig='CONFIG_BLK_DEV_LOOP'
	export commit='e445e46642deb36af94d8289f6351b122e6bd8f1'
	export kconfig='x86_64-rhel-7.2'
	export compiler='gcc-6'
	export rootfs='debian-x86_64-2016-08-31.cgz'
	export enqueue_time='2017-05-02 05:26:28 +0800'
	export _id='5907a8010b9a93884187f9f1'
	export _rt='/result/ltp/containers/nhm-white2/debian-x86_64-2016-08-31.cgz/x86_64-rhel-7.2/gcc-6/e445e46642deb36af94d8289f6351b122e6bd8f1'
	export user='lkp'
	export head_commit='d246ca8c98b5a19308378b4a27fb7d2c167509da'
	export base_commit='5a7ad1146caa895ad718a534399e38bd2ba721b7'
	export branch='linux-devel/devel-hourly-2017050108'
	export result_root='/result/ltp/containers/nhm-white2/debian-x86_64-2016-08-31.cgz/x86_64-rhel-7.2/gcc-6/e445e46642deb36af94d8289f6351b122e6bd8f1/0'
	export LKP_SERVER='inn'
	export max_uptime=3600
	export initrd='/osimage/debian/debian-x86_64-2016-08-31.cgz'
	export bootloader_append='root=/dev/ram0
user=lkp
job=/lkp/scheduled/nhm-white2/ltp-containers-debian-x86_64-2016-08-31.cgz-e445e46642deb36af94d8289f6351b122e6bd8f1-20170502-34881-1oevfbd-0.yaml
ARCH=x86_64
kconfig=x86_64-rhel-7.2
branch=linux-devel/devel-hourly-2017050108
commit=e445e46642deb36af94d8289f6351b122e6bd8f1
BOOT_IMAGE=/pkg/linux/x86_64-rhel-7.2/gcc-6/e445e46642deb36af94d8289f6351b122e6bd8f1/vmlinuz-4.11.0-rc8-02027-ge445e46
max_uptime=3600
RESULT_ROOT=/result/ltp/containers/nhm-white2/debian-x86_64-2016-08-31.cgz/x86_64-rhel-7.2/gcc-6/e445e46642deb36af94d8289f6351b122e6bd8f1/0
LKP_SERVER=inn
debug
apic=debug
sysrq_always_enabled
rcupdate.rcu_cpu_stall_timeout=100
net.ifnames=0
printk.devkmsg=on
panic=-1
softlockup_panic=1
nmi_watchdog=panic
oops=panic
load_ramdisk=2
prompt_ramdisk=0
drbd.minor_count=8
systemd.log_level=err
ignore_loglevel
earlyprintk=ttyS0,115200
console=ttyS0,115200
console=tty0
vga=normal
rw'
	export lkp_initrd='/lkp/lkp/lkp-x86_64.cgz'
	export modules_initrd='/pkg/linux/x86_64-rhel-7.2/gcc-6/e445e46642deb36af94d8289f6351b122e6bd8f1/modules.cgz'
	export bm_initrd='/osimage/deps/debian-x86_64-2016-08-31.cgz/lkp_2017-05-01.cgz,/osimage/deps/debian-x86_64-2016-08-31.cgz/rsync-rootfs_2016-11-15.cgz,/osimage/deps/debian-x86_64-2016-08-31.cgz/run-ipconfig_2016-11-15.cgz,/osimage/deps/debian-x86_64-2016-08-31.cgz/ltp_2017-02-15.cgz,/osimage/pkg/debian-x86_64-2016-08-31.cgz/ltp-x86_64_2017-01-03.cgz,/osimage/deps/debian-x86_64-2016-08-31.cgz/hw_2016-11-15.cgz'
	export site='inn'
	export LKP_CGI_PORT=80
	export LKP_CIFS_PORT=139
	export kernel='/pkg/linux/x86_64-rhel-7.2/gcc-6/e445e46642deb36af94d8289f6351b122e6bd8f1/vmlinuz-4.11.0-rc8-02027-ge445e46'
	export dequeue_time='2017-05-02 05:30:47 +0800'
	export job_initrd='/lkp/scheduled/nhm-white2/ltp-containers-debian-x86_64-2016-08-31.cgz-e445e46642deb36af94d8289f6351b122e6bd8f1-20170502-34881-1oevfbd-0.cgz'

	[ -n "$LKP_SRC" ] ||
	export LKP_SRC=/lkp/${user:-lkp}/src
}

run_job()
{
	echo $$ > $TMP/run-job.pid

	. $LKP_SRC/lib/http.sh
	. $LKP_SRC/lib/job.sh
	. $LKP_SRC/lib/env.sh

	export_top_env

	run_monitor $LKP_SRC/monitors/wrapper kmsg
	run_monitor $LKP_SRC/monitors/wrapper heartbeat
	run_monitor $LKP_SRC/monitors/wrapper oom-killer
	run_monitor $LKP_SRC/monitors/plain/watchdog
	run_monitor $LKP_SRC/monitors/wrapper nfs-hang

	run_test test='containers' $LKP_SRC/tests/wrapper ltp
}

extract_stats()
{
	$LKP_SRC/stats/wrapper ltp
	$LKP_SRC/stats/wrapper kmsg

	$LKP_SRC/stats/wrapper time ltp.time
	$LKP_SRC/stats/wrapper time
	$LKP_SRC/stats/wrapper dmesg
	$LKP_SRC/stats/wrapper kmsg
	$LKP_SRC/stats/wrapper stderr
	$LKP_SRC/stats/wrapper last_state
}

"$@"

--Q0rSlbzrZN6k9QnT
Content-Type: application/octet-stream
Content-Disposition: attachment; filename="dmesg.xz"
Content-Transfer-Encoding: base64

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
vecBoNYKO36GqbHEZ/sCAAAAAARZWg==

--Q0rSlbzrZN6k9QnT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=ltp

2017-05-02 05:31:27 ./runltp -f containers
INFO: creating /lkp/benchmarks/ltp/output directory
INFO: creating /lkp/benchmarks/ltp/results directory
Checking for required user/group ids

'nobody' user id and group found.
'bin' user id and group found.
'daemon' user id and group found.
Users group found.
Sys group found.
Required users/groups exist.
If some fields are empty or look unusual you may have an old version.
Compare to the current minimal requirements in Documentation/Changes.
 
PRETTY_NAME="Debian GNU/Linux stretch/sid"
NAME="Debian GNU/Linux"
ID=debian
HOME_URL="https://www.debian.org/"
SUPPORT_URL="https://www.debian.org/support"
BUG_REPORT_URL="https://bugs.debian.org/"
Linux nhm-white2 4.11.0-rc8-02027-ge445e46 #1 SMP Fri Apr 28 14:39:48 CST 2017 x86_64 GNU/Linux
 
Gnu C                 
util-linux             linux 2.28.1
mount                  mountinfo, assert, debug)
modutils               23
e2fsprogs              1.43.1
Linux C Library        > libc.2.23
Dynamic linker (ldd)   2.23
Procps                 3.3.12
Net-tools              2.10-alpha
iproute2              iproute2-ss161212
Kbd                    69:
Sh-utils               8.25
Modules Loaded         rpcsec_gss_krb5 auth_rpcgss nfsv4 dns_resolver netconsole sr_mod sd_mod cdrom sg snd_hda_codec_realtek ata_generic pata_acpi snd_hda_codec_generic snd_hda_codec_hdmi intel_powerclamp coretemp kvm_intel uas kvm ata_piix irqbypass dcdbas i7core_edac dell_smm_hwmon crc32c_intel pcspkr snd_hda_intel serio_raw edac_core usb_storage libata snd_hda_codec firewire_ohci snd_hda_core firewire_core snd_hwdep crc_itu_t snd_pcm snd_timer snd soundcore shpchp acpi_cpufreq ip_tables broadcom bcm_phy_lib

free reports:
              total        used        free      shared  buff/cache   available
Mem:        4034308      118180     3004756        9020      911372     3685276
Swap:             0           0           0

/proc/cpuinfo
processor	: 0
vendor_id	: GenuineIntel
cpu family	: 6
model		: 30
model name	: Intel(R) Core(TM) i7 CPU         870  @ 2.93GHz
stepping	: 5
microcode	: 0x3
cpu MHz		: 2926.009
cache size	: 8192 KB
physical id	: 0
siblings	: 8
core id		: 0
cpu cores	: 4
apicid		: 0
initial apicid	: 0
fpu		: yes
fpu_exception	: yes
cpuid level	: 11
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf pni dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm sse4_1 sse4_2 popcnt lahf_lm tpr_shadow vnmi flexpriority ept vpid dtherm
bugs		:
bogomips	: 5852.01
clflush size	: 64
cache_alignment	: 64
address sizes	: 36 bits physical, 48 bits virtual
power management:

processor	: 1
vendor_id	: GenuineIntel
cpu family	: 6
model		: 30
model name	: Intel(R) Core(TM) i7 CPU         870  @ 2.93GHz
stepping	: 5
microcode	: 0x3
cpu MHz		: 2926.009
cache size	: 8192 KB
physical id	: 0
siblings	: 8
core id		: 1
cpu cores	: 4
apicid		: 2
initial apicid	: 2
fpu		: yes
fpu_exception	: yes
cpuid level	: 11
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf pni dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm sse4_1 sse4_2 popcnt lahf_lm tpr_shadow vnmi flexpriority ept vpid dtherm
bugs		:
bogomips	: 5850.97
clflush size	: 64
cache_alignment	: 64
address sizes	: 36 bits physical, 48 bits virtual
power management:

processor	: 2
vendor_id	: GenuineIntel
cpu family	: 6
model		: 30
model name	: Intel(R) Core(TM) i7 CPU         870  @ 2.93GHz
stepping	: 5
microcode	: 0x3
cpu MHz		: 2926.009
cache size	: 8192 KB
physical id	: 0
siblings	: 8
core id		: 2
cpu cores	: 4
apicid		: 4
initial apicid	: 4
fpu		: yes
fpu_exception	: yes
cpuid level	: 11
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf pni dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm sse4_1 sse4_2 popcnt lahf_lm tpr_shadow vnmi flexpriority ept vpid dtherm
bugs		:
bogomips	: 5850.98
clflush size	: 64
cache_alignment	: 64
address sizes	: 36 bits physical, 48 bits virtual
power management:

processor	: 3
vendor_id	: GenuineIntel
cpu family	: 6
model		: 30
model name	: Intel(R) Core(TM) i7 CPU         870  @ 2.93GHz
stepping	: 5
microcode	: 0x3
cpu MHz		: 2926.009
cache size	: 8192 KB
physical id	: 0
siblings	: 8
core id		: 3
cpu cores	: 4
apicid		: 6
initial apicid	: 6
fpu		: yes
fpu_exception	: yes
cpuid level	: 11
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf pni dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm sse4_1 sse4_2 popcnt lahf_lm tpr_shadow vnmi flexpriority ept vpid dtherm
bugs		:
bogomips	: 5850.97
clflush size	: 64
cache_alignment	: 64
address sizes	: 36 bits physical, 48 bits virtual
power management:

processor	: 4
vendor_id	: GenuineIntel
cpu family	: 6
model		: 30
model name	: Intel(R) Core(TM) i7 CPU         870  @ 2.93GHz
stepping	: 5
microcode	: 0x3
cpu MHz		: 2926.009
cache size	: 8192 KB
physical id	: 0
siblings	: 8
core id		: 0
cpu cores	: 4
apicid		: 1
initial apicid	: 1
fpu		: yes
fpu_exception	: yes
cpuid level	: 11
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf pni dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm sse4_1 sse4_2 popcnt lahf_lm tpr_shadow vnmi flexpriority ept vpid dtherm
bugs		:
bogomips	: 5850.98
clflush size	: 64
cache_alignment	: 64
address sizes	: 36 bits physical, 48 bits virtual
power management:

processor	: 5
vendor_id	: GenuineIntel
cpu family	: 6
model		: 30
model name	: Intel(R) Core(TM) i7 CPU         870  @ 2.93GHz
stepping	: 5
microcode	: 0x3
cpu MHz		: 2926.009
cache size	: 8192 KB
physical id	: 0
siblings	: 8
core id		: 1
cpu cores	: 4
apicid		: 3
initial apicid	: 3
fpu		: yes
fpu_exception	: yes
cpuid level	: 11
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf pni dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm sse4_1 sse4_2 popcnt lahf_lm tpr_shadow vnmi flexpriority ept vpid dtherm
bugs		:
bogomips	: 5850.97
clflush size	: 64
cache_alignment	: 64
address sizes	: 36 bits physical, 48 bits virtual
power management:

processor	: 6
vendor_id	: GenuineIntel
cpu family	: 6
model		: 30
model name	: Intel(R) Core(TM) i7 CPU         870  @ 2.93GHz
stepping	: 5
microcode	: 0x3
cpu MHz		: 2926.009
cache size	: 8192 KB
physical id	: 0
siblings	: 8
core id		: 2
cpu cores	: 4
apicid		: 5
initial apicid	: 5
fpu		: yes
fpu_exception	: yes
cpuid level	: 11
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf pni dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm sse4_1 sse4_2 popcnt lahf_lm tpr_shadow vnmi flexpriority ept vpid dtherm
bugs		:
bogomips	: 5850.98
clflush size	: 64
cache_alignment	: 64
address sizes	: 36 bits physical, 48 bits virtual
power management:

processor	: 7
vendor_id	: GenuineIntel
cpu family	: 6
model		: 30
model name	: Intel(R) Core(TM) i7 CPU         870  @ 2.93GHz
stepping	: 5
microcode	: 0x3
cpu MHz		: 2926.009
cache size	: 8192 KB
physical id	: 0
siblings	: 8
core id		: 3
cpu cores	: 4
apicid		: 7
initial apicid	: 7
fpu		: yes
fpu_exception	: yes
cpuid level	: 11
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf pni dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm sse4_1 sse4_2 popcnt lahf_lm tpr_shadow vnmi flexpriority ept vpid dtherm
bugs		:
bogomips	: 5850.95
clflush size	: 64
cache_alignment	: 64
address sizes	: 36 bits physical, 48 bits virtual
power management:

no big block device was specified on commandline.
Tests which require a big block device are disabled.
You can specify it with option -z
COMMAND:    /lkp/benchmarks/ltp/bin/ltp-pan  -e -S   -a 9542     -n 9542  -p  -f /tmp/ltp-zhbiygX3Vt/alltests -l /lkp/benchmarks/ltp/results/LTP_RUN_ON-2017_05_02-05h_31m_27s.log  -C /lkp/benchmarks/ltp/output/LTP_RUN_ON-2017_05_02-05h_31m_27s.failed -T /lkp/benchmarks/ltp/output/LTP_RUN_ON-2017_05_02-05h_31m_27s.tconf
LOG File: /lkp/benchmarks/ltp/results/LTP_RUN_ON-2017_05_02-05h_31m_27s.log
FAILED COMMAND File: /lkp/benchmarks/ltp/output/LTP_RUN_ON-2017_05_02-05h_31m_27s.failed
TCONF COMMAND File: /lkp/benchmarks/ltp/output/LTP_RUN_ON-2017_05_02-05h_31m_27s.tconf
Running tests.......
<<<test_start>>>
tag=pidns01 stime=1493674288
cmdline="pidns01"
contacts=""
analysis=exit
<<<test_output>>>
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pidns02 stime=1493674288
cmdline="pidns02"
contacts=""
analysis=exit
<<<test_output>>>
Checking session id & group id inside container
Success: Got Group ID = 1 & Session ID = 1
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pidns03 stime=1493674288
cmdline="pidns03"
contacts=""
analysis=exit
<<<test_output>>>
pidns03     1  TPASS  :  mounting procfs in a new namespace
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pidns04 stime=1493674288
cmdline="pidns04"
contacts=""
analysis=exit
<<<test_output>>>
PIDNS test is running inside container
pidns04     1  TPASS  :  Container init : I was not killed !
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pidns05 stime=1493674288
cmdline="pidns05"
contacts=""
analysis=exit
<<<test_output>>>
pidns05     0  TINFO  :   5 Nested Containers are created
pidns05     1  TPASS  :  The number of containers killed are 2
<<<execution_status>>>
initiation_status="ok"
duration=1 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pidns06 stime=1493674289
cmdline="pidns06"
contacts=""
analysis=exit
<<<test_output>>>
pidns06     0  TINFO  :  Parent: Passing the pid of the process 9691
Container: killing parent pid=9691 failed as expected with ESRCH
Container: killing non-existent pid failed as expected with ESRCH
pidns06     0  TINFO  :  Parent: Passing the pid of the process 9691
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pidns10 stime=1493674289
cmdline="pidns10"
contacts=""
analysis=exit
<<<test_output>>>
cinit: kill(-1, sig) failed with -1 / ESRCH as expected
<<<execution_status>>>
initiation_status="ok"
duration=1 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pidns12 stime=1493674290
cmdline="pidns12"
contacts=""
analysis=exit
<<<test_output>>>
pidns12     0  TINFO  :  parent: PID is 9697
pidns12     1  TPASS  :  cinit: signalling PID (from other namespace) is 0 as expected
pidns12     0  TINFO  :  parent: PID is 9697
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pidns13 stime=1493674290
cmdline="pidns13"
contacts=""
analysis=exit
<<<test_output>>>
pidns13     0  TINFO  :  cinit2: writing some data in pipe
pidns13     0  TINFO  :  cinit1: setup handler for async I/O on pipe
pidns13     1  TPASS  :  cinit1: si_fd is 7, si_code is 1
<<<execution_status>>>
initiation_status="ok"
duration=2 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pidns16 stime=1493674292
cmdline="pidns16"
contacts=""
analysis=exit
<<<test_output>>>
pidns16     1  TPASS  :  container init continued successfuly, after handling signal -USR1
<<<execution_status>>>
initiation_status="ok"
duration=2 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pidns17 stime=1493674294
cmdline="pidns17"
contacts=""
analysis=exit
<<<test_output>>>
cinit: all children have terminated.
<<<execution_status>>>
initiation_status="ok"
duration=1 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pidns20 stime=1493674295
cmdline="pidns20"
contacts=""
analysis=exit
<<<test_output>>>
pidns20     0  TINFO  :  cinit: blocked SIGUSR1
pidns20     0  TINFO  :  cinit: unblocking SIGUSR1
pidns20     1  TPASS  :  cinit: user function is called as expected
pidns20     0  TINFO  :  parent: signalled SIGUSR1 to container
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=1 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pidns30 stime=1493674295
cmdline="pidns30"
contacts=""
analysis=exit
<<<test_output>>>
mq_open succeeded
successfully registered for notification
successfully registered handler for SIGUSR1
signal originator PID = 0
parent is done - cleaning up
pidns30     0  TINFO  :  successfully created posix mqueue
pidns30     0  TINFO  :  mq_send succeeded
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pidns31 stime=1493674295
cmdline="pidns31"
contacts=""
analysis=exit
<<<test_output>>>
pidns31     0  TINFO  :  parent: successfully created posix mqueue
pidns31     0  TINFO  :  cinit: my father is ready to receive a message
pidns31     0  TINFO  :  cinit: mq_open succeeded
pidns31     0  TINFO  :  cinit: mq_send() succeeded
pidns31     0  TINFO  :  parent: successfully created posix mqueue
pidns31     0  TINFO  :  parent: successfully created child (pid = 9728)
pidns31     0  TINFO  :  parent: successfully registered for notification
pidns31     0  TINFO  :  parent: successfully registered handler for SIGUSR1
pidns31     1  TPASS  :  father: signal originator PID = 9728
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pidns32 stime=1493674295
cmdline="pidns32"
contacts=""
analysis=exit
<<<test_output>>>
pidns32     0  TINFO  :  Child process returned TPASS
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=mqns_01 stime=1493674295
cmdline="mqns_01"
contacts=""
analysis=exit
<<<test_output>>>
posixmq_namespace_01    0  TINFO  :  Testing posix mq namespaces through unshare(2).
posixmq_namespace_01    0  TINFO  :  Checking namespaces isolation from parent to child
posixmq_namespace_01    1  TPASS  :  child process didn't find mqueue
posixmq_namespace_01    0  TINFO  :  Testing posix mq namespaces through unshare(2).
posixmq_namespace_01    0  TINFO  :  Checking namespaces isolation from parent to child
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mqns_01_clone stime=1493674295
cmdline="mqns_01 -clone"
contacts=""
analysis=exit
<<<test_output>>>
posixmq_namespace_01    0  TINFO  :  Testing posix mq namespaces through clone(2).
posixmq_namespace_01    0  TINFO  :  Checking namespaces isolation from parent to child
posixmq_namespace_01    0  TINFO  :  Testing posix mq namespaces through clone(2).
posixmq_namespace_01    0  TINFO  :  Checking namespaces isolation from parent to child
posixmq_namespace_01    1  TPASS  :  child process didn't find mqueue
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mqns_02 stime=1493674295
cmdline="mqns_02"
contacts=""
analysis=exit
<<<test_output>>>
posixmq_namespace_02    0  TINFO  :  Testing posix mq namespaces through unshare(2).
posixmq_namespace_02    0  TINFO  :  Checking namespaces isolation (child to parent)
posixmq_namespace_02    1  TPASS  :  Parent process can't see the mqueue
posixmq_namespace_02    0  TINFO  :  Testing posix mq namespaces through unshare(2).
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mqns_02_clone stime=1493674295
cmdline="mqns_02 -clone"
contacts=""
analysis=exit
<<<test_output>>>
posixmq_namespace_02    0  TINFO  :  Testing posix mq namespaces through clone(2).
posixmq_namespace_02    0  TINFO  :  Testing posix mq namespaces through clone(2).
posixmq_namespace_02    0  TINFO  :  Checking namespaces isolation (child to parent)
posixmq_namespace_02    1  TPASS  :  Parent process can't see the mqueue
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mqns_03 stime=1493674295
cmdline="mqns_03"
contacts=""
analysis=exit
<<<test_output>>>
posixmq_namespace_03    0  TINFO  :  Testing posix mq namespaces through unshare(2)
posixmq_namespace_03    0  TINFO  :  Testing posix mq namespaces through unshare(2)
posixmq_namespace_03    0  TINFO  :  Checking correct umount+remount of mqueuefs
posixmq_namespace_03    1  TPASS  :  umount+remount of mqueuefs remounted the right fs
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mqns_03_clone stime=1493674295
cmdline="mqns_03 -clone"
contacts=""
analysis=exit
<<<test_output>>>
posixmq_namespace_03    0  TINFO  :  Testing posix mq namespaces through clone(2)
posixmq_namespace_03    0  TINFO  :  Testing posix mq namespaces through clone(2)
posixmq_namespace_03    0  TINFO  :  Checking correct umount+remount of mqueuefs
posixmq_namespace_03    1  TPASS  :  umount+remount of mqueuefs remounted the right fs
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=1 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mqns_04 stime=1493674295
cmdline="mqns_04"
contacts=""
analysis=exit
<<<test_output>>>
posixmq_namespace_04    0  TINFO  :  Testing posix mq namespaces through unshare(2).
posixmq_namespace_04    0  TINFO  :  Checking mqueue filesystem lifetime
posixmq_namespace_04    0  TINFO  :  Testing posix mq namespaces through unshare(2).
posixmq_namespace_04    0  TINFO  :  Checking mqueue filesystem lifetime
posixmq_namespace_04    1  TPASS  :  Child mqueue fs still visible for parent
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mqns_04_clone stime=1493674295
cmdline="mqns_04 -clone"
contacts=""
analysis=exit
<<<test_output>>>
posixmq_namespace_04    0  TINFO  :  Testing posix mq namespaces through clone(2).
posixmq_namespace_04    0  TINFO  :  Checking mqueue filesystem lifetime
posixmq_namespace_04    0  TINFO  :  Testing posix mq namespaces through clone(2).
posixmq_namespace_04    0  TINFO  :  Checking mqueue filesystem lifetime
posixmq_namespace_04    1  TPASS  :  Child mqueue fs still visible for parent
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=netns_netlink stime=1493674295
cmdline="netns_netlink"
contacts=""
analysis=exit
<<<test_output>>>
netns_netlink    1  TPASS  :  netlink interface pass
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=netns_breakns_ns_exec_ipv4_netlink stime=1493674295
cmdline="netns_breakns.sh ns_exec ipv4 netlink"
contacts=""
analysis=exit
<<<test_output>>>
netns_breakns_ns_exec_ipv4_netlink 1 TINFO : NS interaction: ns_exec | devices setup: netlink
netns_breakns_ns_exec_ipv4_netlink 1 TPASS : controlling device over netlink
netns_breakns_ns_exec_ipv4_netlink 2 TPASS : controlling device over ioctl
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=2 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=netns_breakns_ns_exec_ipv6_netlink stime=1493674295
cmdline="netns_breakns.sh ns_exec ipv6 netlink"
contacts=""
analysis=exit
<<<test_output>>>
netns_breakns_ns_exec_ipv6_netlink 1 TINFO : NS interaction: ns_exec | devices setup: netlink
netns_breakns_ns_exec_ipv6_netlink 1 TPASS : controlling device over netlink
netns_breakns_ns_exec_ipv6_netlink 2 TPASS : controlling device over ioctl
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=1 cstime=2
<<<test_end>>>
<<<test_start>>>
tag=netns_breakns_ns_exec_ipv4_ioctl stime=1493674295
cmdline="netns_breakns.sh ns_exec ipv4 ioctl"
contacts=""
analysis=exit
<<<test_output>>>
netns_breakns_ns_exec_ipv4_ioctl 1 TINFO : NS interaction: ns_exec | devices setup: ioctl
netns_breakns_ns_exec_ipv4_ioctl 1 TPASS : controlling device over netlink
netns_breakns_ns_exec_ipv4_ioctl 2 TPASS : controlling device over ioctl
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=1 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=netns_breakns_ns_exec_ipv6_ioctl stime=1493674295
cmdline="netns_breakns.sh ns_exec ipv6 ioctl"
contacts=""
analysis=exit
<<<test_output>>>
netns_breakns_ns_exec_ipv6_ioctl 1 TINFO : NS interaction: ns_exec | devices setup: ioctl
netns_breakns_ns_exec_ipv6_ioctl 1 TPASS : controlling device over netlink
netns_breakns_ns_exec_ipv6_ioctl 2 TPASS : controlling device over ioctl
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=2 cstime=2
<<<test_end>>>
<<<test_start>>>
tag=netns_breakns_ip_ipv4_netlink stime=1493674295
cmdline="netns_breakns.sh ip ipv4 netlink"
contacts=""
analysis=exit
<<<test_output>>>
netns_breakns_ip_ipv4_netlink 1 TINFO : NS interaction: ip | devices setup: netlink
netns_breakns_ip_ipv4_netlink 1 TPASS : controlling device over netlink
netns_breakns_ip_ipv4_netlink 2 TPASS : controlling device over ioctl
<<<execution_status>>>
initiation_status="ok"
duration=1 termination_type=exited termination_id=0 corefile=no
cutime=1 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=netns_breakns_ip_ipv6_netlink stime=1493674296
cmdline="netns_breakns.sh ip ipv6 netlink"
contacts=""
analysis=exit
<<<test_output>>>
netns_breakns_ip_ipv6_netlink 1 TINFO : NS interaction: ip | devices setup: netlink
netns_breakns_ip_ipv6_netlink 1 TPASS : controlling device over netlink
netns_breakns_ip_ipv6_netlink 2 TPASS : controlling device over ioctl
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=2 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=netns_breakns_ip_ipv4_ioctl stime=1493674296
cmdline="netns_breakns.sh ip ipv4 ioctl"
contacts=""
analysis=exit
<<<test_output>>>
netns_breakns_ip_ipv4_ioctl 1 TINFO : NS interaction: ip | devices setup: ioctl
netns_breakns_ip_ipv4_ioctl 1 TPASS : controlling device over netlink
netns_breakns_ip_ipv4_ioctl 2 TPASS : controlling device over ioctl
<<<execution_status>>>
initiation_status="ok"
duration=1 termination_type=exited termination_id=0 corefile=no
cutime=2 cstime=2
<<<test_end>>>
<<<test_start>>>
tag=netns_breakns_ip_ipv6_ioctl stime=1493674297
cmdline="netns_breakns.sh ip ipv6 ioctl"
contacts=""
analysis=exit
<<<test_output>>>
netns_breakns_ip_ipv6_ioctl 1 TINFO : NS interaction: ip | devices setup: ioctl
netns_breakns_ip_ipv6_ioctl 1 TPASS : controlling device over netlink
netns_breakns_ip_ipv6_ioctl 2 TPASS : controlling device over ioctl
<<<execution_status>>>
initiation_status="ok"
duration=1 termination_type=exited termination_id=0 corefile=no
cutime=1 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=netns_comm_ns_exec_ipv4_netlink stime=1493674298
cmdline="netns_comm.sh ns_exec ipv4 netlink"
contacts=""
analysis=exit
<<<test_output>>>
netns_comm_ns_exec_ipv4_netlink 1 TINFO : NS interaction: ns_exec | devices setup: netlink
netns_comm_ns_exec_ipv4_netlink 1 TPASS : configuration and communication over veth0
netns_comm_ns_exec_ipv4_netlink 2 TPASS : configuration and communication over veth1
netns_comm_ns_exec_ipv4_netlink 3 TPASS : configuration and communication over localhost
<<<execution_status>>>
initiation_status="ok"
duration=3 termination_type=exited termination_id=0 corefile=no
cutime=2 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=netns_comm_ns_exec_ipv6_netlink stime=1493674301
cmdline="netns_comm.sh ns_exec ipv6 netlink"
contacts=""
analysis=exit
<<<test_output>>>
netns_comm_ns_exec_ipv6_netlink 1 TINFO : NS interaction: ns_exec | devices setup: netlink
netns_comm_ns_exec_ipv6_netlink 1 TFAIL : configuration and communication over veth0
netns_comm_ns_exec_ipv6_netlink 2 TFAIL : configuration and communication over veth1
netns_comm_ns_exec_ipv6_netlink 3 TPASS : configuration and communication over localhost
<<<execution_status>>>
initiation_status="ok"
duration=23 termination_type=exited termination_id=1 corefile=no
cutime=2 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=netns_comm_ns_exec_ipv4_ioctl stime=1493674324
cmdline="netns_comm.sh ns_exec ipv4 ioctl"
contacts=""
analysis=exit
<<<test_output>>>
netns_comm_ns_exec_ipv4_ioctl 1 TINFO : NS interaction: ns_exec | devices setup: ioctl
netns_comm_ns_exec_ipv4_ioctl 1 TPASS : configuration and communication over veth0
netns_comm_ns_exec_ipv4_ioctl 2 TPASS : configuration and communication over veth1
netns_comm_ns_exec_ipv4_ioctl 3 TPASS : configuration and communication over localhost
<<<execution_status>>>
initiation_status="ok"
duration=3 termination_type=exited termination_id=0 corefile=no
cutime=1 cstime=2
<<<test_end>>>
<<<test_start>>>
tag=netns_comm_ns_exec_ipv6_ioctl stime=1493674327
cmdline="netns_comm.sh ns_exec ipv6 ioctl"
contacts=""
analysis=exit
<<<test_output>>>
netns_comm_ns_exec_ipv6_ioctl 1 TINFO : NS interaction: ns_exec | devices setup: ioctl
netns_comm_ns_exec_ipv6_ioctl 1 TFAIL : configuration and communication over veth0
netns_comm_ns_exec_ipv6_ioctl 2 TFAIL : configuration and communication over veth1
netns_comm_ns_exec_ipv6_ioctl 3 TPASS : configuration and communication over localhost
<<<execution_status>>>
initiation_status="ok"
duration=23 termination_type=exited termination_id=1 corefile=no
cutime=2 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=netns_comm_ip_ipv4_netlink stime=1493674350
cmdline="netns_comm.sh ip ipv4 netlink"
contacts=""
analysis=exit
<<<test_output>>>
netns_comm_ip_ipv4_netlink 1 TINFO : NS interaction: ip | devices setup: netlink
netns_comm_ip_ipv4_netlink 1 TPASS : configuration and communication over veth0
netns_comm_ip_ipv4_netlink 2 TPASS : configuration and communication over veth1
netns_comm_ip_ipv4_netlink 3 TPASS : configuration and communication over localhost
<<<execution_status>>>
initiation_status="ok"
duration=4 termination_type=exited termination_id=0 corefile=no
cutime=1 cstime=2
<<<test_end>>>
<<<test_start>>>
tag=netns_comm_ip_ipv6_netlink stime=1493674354
cmdline="netns_comm.sh ip ipv6 netlink"
contacts=""
analysis=exit
<<<test_output>>>
netns_comm_ip_ipv6_netlink 1 TINFO : NS interaction: ip | devices setup: netlink
netns_comm_ip_ipv6_netlink 1 TFAIL : configuration and communication over veth0
netns_comm_ip_ipv6_netlink 2 TFAIL : configuration and communication over veth1
netns_comm_ip_ipv6_netlink 3 TPASS : configuration and communication over localhost
<<<execution_status>>>
initiation_status="ok"
duration=23 termination_type=exited termination_id=1 corefile=no
cutime=1 cstime=2
<<<test_end>>>
<<<test_start>>>
tag=netns_comm_ip_ipv4_ioctl stime=1493674377
cmdline="netns_comm.sh ip ipv4 ioctl"
contacts=""
analysis=exit
<<<test_output>>>
netns_comm_ip_ipv4_ioctl 1 TINFO : NS interaction: ip | devices setup: ioctl
netns_comm_ip_ipv4_ioctl 1 TPASS : configuration and communication over veth0
netns_comm_ip_ipv4_ioctl 2 TPASS : configuration and communication over veth1
netns_comm_ip_ipv4_ioctl 3 TPASS : configuration and communication over localhost
<<<execution_status>>>
initiation_status="ok"
duration=4 termination_type=exited termination_id=0 corefile=no
cutime=2 cstime=2
<<<test_end>>>
<<<test_start>>>
tag=netns_comm_ip_ipv6_ioctl stime=1493674381
cmdline="netns_comm.sh ip ipv6 ioctl"
contacts=""
analysis=exit
<<<test_output>>>
netns_comm_ip_ipv6_ioctl 1 TINFO : NS interaction: ip | devices setup: ioctl
netns_comm_ip_ipv6_ioctl 1 TFAIL : configuration and communication over veth0
netns_comm_ip_ipv6_ioctl 2 TFAIL : configuration and communication over veth1
netns_comm_ip_ipv6_ioctl 3 TPASS : configuration and communication over localhost
<<<execution_status>>>
initiation_status="ok"
duration=23 termination_type=exited termination_id=1 corefile=no
cutime=2 cstime=2
<<<test_end>>>
<<<test_start>>>
tag=netns_sysfs stime=1493674404
cmdline="netns_sysfs.sh"
contacts=""
analysis=exit
<<<test_output>>>
netns_sysfs 1 TPASS : sysfs in new namespace has dummy_test1 interface
netns_sysfs 2 TPASS : sysfs in new namespace does not have dummy_test0 interface
netns_sysfs 3 TPASS : sysfs not affected by a separate namespace
<<<execution_status>>>
initiation_status="ok"
duration=1 termination_type=exited termination_id=0 corefile=no
cutime=1 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=shmnstest_none stime=1493674405
cmdline="shmnstest none"
contacts=""
analysis=exit
<<<test_output>>>
sysvipc_namespace    0  TINFO  :  shmid namespaces test : none
sysvipc_namespace    0  TINFO  :  shmid namespaces test : none
sysvipc_namespace    1  TPASS  :  plain cloned process found shmid
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=shmnstest_clone stime=1493674405
cmdline="shmnstest clone"
contacts=""
analysis=exit
<<<test_output>>>
sysvipc_namespace    0  TINFO  :  shmid namespaces test : clone
sysvipc_namespace    0  TINFO  :  shmid namespaces test : clone
sysvipc_namespace    1  TPASS  :  clone: child process didn't find shmid
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=shmnstest_unshare stime=1493674405
cmdline="shmnstest unshare"
contacts=""
analysis=exit
<<<test_output>>>
sysvipc_namespace    0  TINFO  :  shmid namespaces test : unshare
sysvipc_namespace    0  TINFO  :  shmid namespaces test : unshare
sysvipc_namespace    1  TPASS  :  unshare: child process didn't find shmid
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=shmem_2nstest_none stime=1493674405
cmdline="shmem_2nstest none"
contacts=""
analysis=exit
<<<test_output>>>
shmem_2nstest    0  TINFO  :  Shared Memory namespace test : none
shmem_2nstest    0  TINFO  :  Cont1: Able to create shared mem segment
shmem_2nstest    0  TINFO  :  Shared Memory namespace test : none
shmem_2nstest    0  TINFO  :  Shared Memory namespace test : none
shmem_2nstest    1  TPASS  :  Plain cloned process able to access shmem segment created
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=shmem_2nstest_clone stime=1493674405
cmdline="shmem_2nstest clone"
contacts=""
analysis=exit
<<<test_output>>>
shmem_2nstest    0  TINFO  :  Shared Memory namespace test : clone
shmem_2nstest    0  TINFO  :  Cont1: Able to create shared mem segment
shmem_2nstest    0  TINFO  :  Shared Memory namespace test : clone
shmem_2nstest    0  TINFO  :  Cont2: Able to allocate shmem seg with the same key
shmem_2nstest    0  TINFO  :  Shared Memory namespace test : clone
shmem_2nstest    1  TPASS  :  clone : In namespace2 unable to access the shmem seg created in Namespace1
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=shmem_2nstest_unshare stime=1493674405
cmdline="shmem_2nstest unshare"
contacts=""
analysis=exit
<<<test_output>>>
shmem_2nstest    0  TINFO  :  Shared Memory namespace test : unshare
shmem_2nstest    0  TINFO  :  Cont1: Able to create shared mem segment
shmem_2nstest    0  TINFO  :  Shared Memory namespace test : unshare
shmem_2nstest    0  TINFO  :  Cont2: Able to allocate shmem seg with the same key
shmem_2nstest    0  TINFO  :  Shared Memory namespace test : unshare
shmem_2nstest    1  TPASS  :  unshare : In namespace2 unable to access the shmem seg created in Namespace1
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=shm_comm stime=1493674405
cmdline="shm_comm"
contacts=""
analysis=exit
<<<test_output>>>
shm_comm    1  TPASS  :  SysV shm: communication with identical keys between namespaces
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mesgq_nstest_none stime=1493674405
cmdline="mesgq_nstest none"
contacts=""
analysis=exit
<<<test_output>>>
mesgq_nstest    0  TINFO  :  mesgq namespaces test : none
mesgq_nstest    0  TINFO  :  Mesg read of 18 bytes; Type 5: Msg: Message of type 5!
mesgq_nstest    0  TINFO  :  mesgq namespaces test : none
mesgq_nstest    1  TPASS  :  Plain cloned process found mesgq inside container
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=mesgq_nstest_clone stime=1493674405
cmdline="mesgq_nstest clone"
contacts=""
analysis=exit
<<<test_output>>>
mesgq_nstest    0  TINFO  :  mesgq namespaces test : clone
mesgq_nstest    0  TINFO  :  mesgq namespaces test : clone
mesgq_nstest    1  TPASS  :  clone: Container didn't find mesgq
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mesgq_nstest_unshare stime=1493674405
cmdline="mesgq_nstest unshare"
contacts=""
analysis=exit
<<<test_output>>>
mesgq_nstest    0  TINFO  :  mesgq namespaces test : unshare
mesgq_nstest    0  TINFO  :  mesgq namespaces test : unshare
mesgq_nstest    1  TPASS  :  unshare: Container didn't find mesgq
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=msg_comm stime=1493674405
cmdline="msg_comm"
contacts=""
analysis=exit
<<<test_output>>>
msg_comm    1  TPASS  :  SysV msg: communication with identical keys between namespaces
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sem_nstest_none stime=1493674405
cmdline="sem_nstest none"
contacts=""
analysis=exit
<<<test_output>>>
sem_nstest    0  TINFO  :  Semaphore namespaces Isolation test : none
sem_nstest    0  TINFO  :  PID 10464: Fetched existing semaphore..id = 32769
sem_nstest    0  TINFO  :  Semaphore namespaces Isolation test : none
sem_nstest    1  TPASS  :  Plain cloned process found semaphore inside container
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sem_nstest_clone stime=1493674405
cmdline="sem_nstest clone"
contacts=""
analysis=exit
<<<test_output>>>
sem_nstest    0  TINFO  :  Semaphore namespaces Isolation test : clone
sem_nstest    0  TINFO  :  Semaphore namespaces Isolation test : clone
sem_nstest    1  TPASS  :  clone: Container didn't find semaphore
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sem_nstest_unshare stime=1493674405
cmdline="sem_nstest unshare"
contacts=""
analysis=exit
<<<test_output>>>
sem_nstest    0  TINFO  :  Semaphore namespaces Isolation test : unshare
sem_nstest    0  TINFO  :  Semaphore namespaces Isolation test : unshare
sem_nstest    1  TPASS  :  unshare: Container didn't find semaphore
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=semtest_2ns_none stime=1493674405
cmdline="semtest_2ns none"
contacts=""
analysis=exit
<<<test_output>>>
semtest_2ns    0  TINFO  :  Semaphore Namespaces Test : none
semtest_2ns    0  TINFO  :  Cont1: Able to create semaphore
semtest_2ns    0  TINFO  :  Semaphore Namespaces Test : none
semtest_2ns    0  TINFO  :  Sem1: File locked, Critical section is updated...
semtest_2ns    0  TINFO  :  Semaphore Namespaces Test : none
semtest_2ns    1  TPASS  :  Plain cloned process able to access the semaphore created
<<<execution_status>>>
initiation_status="ok"
duration=2 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=semtest_2ns_clone stime=1493674407
cmdline="semtest_2ns clone"
contacts=""
analysis=exit
<<<test_output>>>
semtest_2ns    0  TINFO  :  Semaphore Namespaces Test : clone
semtest_2ns    0  TINFO  :  Cont1: Able to create semaphore
semtest_2ns    0  TINFO  :  Semaphore Namespaces Test : clone
semtest_2ns    0  TINFO  :  Cont2: Able to create semaphore with sameKey
semtest_2ns    0  TINFO  :  Semaphore Namespaces Test : clone
semtest_2ns    1  TPASS  :  clone : In namespace2 unable to access the semaphore created in Namespace1
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=semtest_2ns_unshare stime=1493674407
cmdline="semtest_2ns unshare"
contacts=""
analysis=exit
<<<test_output>>>
semtest_2ns    0  TINFO  :  Semaphore Namespaces Test : unshare
semtest_2ns    0  TINFO  :  Cont1: Able to create semaphore
semtest_2ns    0  TINFO  :  Semaphore Namespaces Test : unshare
semtest_2ns    0  TINFO  :  Cont2: Able to create semaphore with sameKey
semtest_2ns    0  TINFO  :  Semaphore Namespaces Test : unshare
semtest_2ns    1  TPASS  :  unshare : In namespace2 unable to access the semaphore created in Namespace1
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sem_comm stime=1493674407
cmdline="sem_comm"
contacts=""
analysis=exit
<<<test_output>>>
sem_comm    1  TPASS  :  SysV sem: communication with identical keys between namespaces
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=1 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=utstest_unshare_1 stime=1493674407
cmdline="utstest unshare 1"
contacts=""
analysis=exit
<<<test_output>>>
uts_namespace    1  TPASS  :  test 1 (unshare): success
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=utstest_unshare_2 stime=1493674407
cmdline="utstest unshare 2"
contacts=""
analysis=exit
<<<test_output>>>
uts_namespace    1  TPASS  :  test 2 (unshare): success
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=utstest_unshare_3 stime=1493674407
cmdline="utstest unshare 3"
contacts=""
analysis=exit
<<<test_output>>>
uts_namespace    1  TPASS  :  test 3 (unshare): success
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=utstest_unshare_4 stime=1493674407
cmdline="utstest unshare 4"
contacts=""
analysis=exit
<<<test_output>>>
uts_namespace    1  TPASS  :  test 4 (unshare): successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=utstest_unshare_5 stime=1493674407
cmdline="utstest unshare 5"
contacts=""
analysis=exit
<<<test_output>>>
uts_namespace    1  TPASS  :  P2: P1 claims error
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=utstest_clone_1 stime=1493674407
cmdline="utstest clone 1"
contacts=""
analysis=exit
<<<test_output>>>
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=utstest_clone_2 stime=1493674407
cmdline="utstest clone 2"
contacts=""
analysis=exit
<<<test_output>>>
uts_namespace    1  TPASS  :  test 2 (clone): success
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=utstest_clone_3 stime=1493674407
cmdline="utstest clone 3"
contacts=""
analysis=exit
<<<test_output>>>
uts_namespace    1  TPASS  :  test 3 (clone): success
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=utstest_clone_4 stime=1493674407
cmdline="utstest clone 4"
contacts=""
analysis=exit
<<<test_output>>>
uts_namespace    1  TPASS  :  test 4 (clone): successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=utstest_clone_5 stime=1493674407
cmdline="utstest clone 5"
contacts=""
analysis=exit
<<<test_output>>>
uts_namespace    1  TPASS  :  P2: P1 claims error
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mountns01 stime=1493674407
cmdline="mountns01"
contacts=""
analysis=exit
<<<test_output>>>
mountns01    1  TPASS  :  shared mount in child passed
mountns01    2  TPASS  :  shared mount in parent passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mountns02 stime=1493674407
cmdline="mountns02"
contacts=""
analysis=exit
<<<test_output>>>
mountns02    1  TPASS  :  private mount in child passed
mountns02    2  TPASS  :  private mount in parent passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mountns03 stime=1493674407
cmdline="mountns03"
contacts=""
analysis=exit
<<<test_output>>>
mountns03    1  TPASS  :  propagation from slave mount passed
mountns03    2  TPASS  :  propagation to slave mount passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mountns04 stime=1493674407
cmdline="mountns04"
contacts=""
analysis=exit
<<<test_output>>>
mountns04    1  TPASS  :  unbindable mount passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=1 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=userns01 stime=1493674407
cmdline="userns01"
contacts=""
analysis=exit
<<<test_output>>>
user_namespace1    0  TINFO  :  Child process returned TPASS
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=userns02 stime=1493674407
cmdline="userns02"
contacts=""
analysis=exit
<<<test_output>>>
user_namespace2    0  TINFO  :  Child process returned TPASS
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=userns03 stime=1493674407
cmdline="userns03"
contacts=""
analysis=exit
<<<test_output>>>
user_namespace3    1  TPASS  :  setgroups can't be re-enabled
user_namespace3    0  TINFO  :  Child process returned TPASS
user_namespace3    0  TINFO  :  Child process returned TPASS
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=userns04 stime=1493674407
cmdline="userns04"
contacts=""
analysis=exit
<<<test_output>>>
user_namespace4    0  TINFO  :  Child process returned TPASS
user_namespace4    0  TINFO  :  Child process returned TPASS
user_namespace4    0  TINFO  :  Child process returned TPASS
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=userns05 stime=1493674407
cmdline="userns05"
contacts=""
analysis=exit
<<<test_output>>>
user_namespace5    0  TINFO  :  Child process returned TPASS
user_namespace5    0  TINFO  :  Child process returned TPASS
user_namespace5    0  TINFO  :  Child process returned TPASS
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=userns06 stime=1493674407
cmdline="userns06"
contacts=""
analysis=exit
<<<test_output>>>
user_namespace6    0  TINFO  :  Child process returned TPASS
user_namespace6    0  TINFO  :  Child process returned TPASS
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=userns07 stime=1493674407
cmdline="userns07"
contacts=""
analysis=exit
<<<test_output>>>
userns07    0  TINFO  :  Child process returned TPASS
incrementing stop
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=1 cstime=1
<<<test_end>>>
INFO: ltp-pan reported some tests FAIL
LTP Version: 20160920-191-g8cc4165e2

       ###############################################################

            Done executing testcases.
            LTP Version:  20160920-191-g8cc4165e2
       ###############################################################


--Q0rSlbzrZN6k9QnT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="job.yaml"

---

#! jobs/ltp.yaml
suite: ltp
testcase: ltp
category: functional
ltp:
  test: containers
job_origin: "/lkp/lkp/.src-20170430-103405/allot/cyclic:linux-devel:devel-hourly/nhm-white2/ltp.yaml"

#! queue options
queue: bisect
testbox: nhm-white2
tbox_group: nhm-white2
submit_id: 5907a8010b9a93884187f9f1
job_file: "/lkp/scheduled/nhm-white2/ltp-containers-debian-x86_64-2016-08-31.cgz-e445e46642deb36af94d8289f6351b122e6bd8f1-20170502-34881-1oevfbd-0.yaml"
id: dcbf87865b925e9dc7c7c2c75c107558a633fa19

#! hosts/nhm-white2
model: Nehalem
memory: 4G
nr_cpu: 8
hdd_partitions: 
swap_partitions: 
rootfs_partition: 
netconsole_port: 6671
brand: Intel(R) Core(TM) i7 CPU 870 @ 2.93GHz

#! include/category/functional
kmsg: 
heartbeat: 

#! include/ltp
need_kconfig: CONFIG_BLK_DEV_LOOP

#! include/queue/cyclic
commit: e445e46642deb36af94d8289f6351b122e6bd8f1

#! include/testbox/nhm-white2
cpufreq_governor: 

#! default params
kconfig: x86_64-rhel-7.2
compiler: gcc-6
rootfs: debian-x86_64-2016-08-31.cgz
enqueue_time: 2017-05-02 05:26:28.043206307 +08:00
_id: 5907a8010b9a93884187f9f1
_rt: "/result/ltp/containers/nhm-white2/debian-x86_64-2016-08-31.cgz/x86_64-rhel-7.2/gcc-6/e445e46642deb36af94d8289f6351b122e6bd8f1"

#! schedule options
user: lkp
head_commit: d246ca8c98b5a19308378b4a27fb7d2c167509da
base_commit: 5a7ad1146caa895ad718a534399e38bd2ba721b7
branch: linux-devel/devel-hourly-2017050108
result_root: "/result/ltp/containers/nhm-white2/debian-x86_64-2016-08-31.cgz/x86_64-rhel-7.2/gcc-6/e445e46642deb36af94d8289f6351b122e6bd8f1/0"
LKP_SERVER: inn
max_uptime: 3600
initrd: "/osimage/debian/debian-x86_64-2016-08-31.cgz"
bootloader_append:
- root=/dev/ram0
- user=lkp
- job=/lkp/scheduled/nhm-white2/ltp-containers-debian-x86_64-2016-08-31.cgz-e445e46642deb36af94d8289f6351b122e6bd8f1-20170502-34881-1oevfbd-0.yaml
- ARCH=x86_64
- kconfig=x86_64-rhel-7.2
- branch=linux-devel/devel-hourly-2017050108
- commit=e445e46642deb36af94d8289f6351b122e6bd8f1
- BOOT_IMAGE=/pkg/linux/x86_64-rhel-7.2/gcc-6/e445e46642deb36af94d8289f6351b122e6bd8f1/vmlinuz-4.11.0-rc8-02027-ge445e46
- max_uptime=3600
- RESULT_ROOT=/result/ltp/containers/nhm-white2/debian-x86_64-2016-08-31.cgz/x86_64-rhel-7.2/gcc-6/e445e46642deb36af94d8289f6351b122e6bd8f1/0
- LKP_SERVER=inn
- debug
- apic=debug
- sysrq_always_enabled
- rcupdate.rcu_cpu_stall_timeout=100
- net.ifnames=0
- printk.devkmsg=on
- panic=-1
- softlockup_panic=1
- nmi_watchdog=panic
- oops=panic
- load_ramdisk=2
- prompt_ramdisk=0
- drbd.minor_count=8
- systemd.log_level=err
- ignore_loglevel
- earlyprintk=ttyS0,115200
- console=ttyS0,115200
- console=tty0
- vga=normal
- rw
lkp_initrd: "/lkp/lkp/lkp-x86_64.cgz"
modules_initrd: "/pkg/linux/x86_64-rhel-7.2/gcc-6/e445e46642deb36af94d8289f6351b122e6bd8f1/modules.cgz"
bm_initrd: "/osimage/deps/debian-x86_64-2016-08-31.cgz/lkp_2017-05-01.cgz,/osimage/deps/debian-x86_64-2016-08-31.cgz/rsync-rootfs_2016-11-15.cgz,/osimage/deps/debian-x86_64-2016-08-31.cgz/run-ipconfig_2016-11-15.cgz,/osimage/deps/debian-x86_64-2016-08-31.cgz/ltp_2017-02-15.cgz,/osimage/pkg/debian-x86_64-2016-08-31.cgz/ltp-x86_64_2017-01-03.cgz,/osimage/deps/debian-x86_64-2016-08-31.cgz/hw_2016-11-15.cgz"
site: inn

#! /lkp/lkp/.src-20170430-234940/include/site/inn
LKP_CGI_PORT: 80
LKP_CIFS_PORT: 139
oom-killer: 
watchdog: 
nfs-hang: 

#! runtime status

#! user overrides
kernel: "/pkg/linux/x86_64-rhel-7.2/gcc-6/e445e46642deb36af94d8289f6351b122e6bd8f1/vmlinuz-4.11.0-rc8-02027-ge445e46"
dequeue_time: 2017-05-02 05:30:47.332166437 +08:00

#! /lkp/lkp/.src-20170501-224816/include/site/inn
job_state: failed
loadavg: '0.09'

--Q0rSlbzrZN6k9QnT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=reproduce

./runltp -f containers

--Q0rSlbzrZN6k9QnT--
