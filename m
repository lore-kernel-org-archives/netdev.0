From: "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Wed, 5 Jan 2005 11:35:00 -0600
Message-ID: <200501051135.03493.jeremy.guthrie@berbee.com>
References: <200501031455.26980.jeremy.guthrie@berbee.com> <200501050918.22472.jeremy.guthrie@berbee.com> <16860.5674.612383.986202@robur.slu.se>
Reply-To: jeremy.guthrie@berbee.com
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2230455.ZoKKAJfLF7";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <16860.5674.612383.986202@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart2230455.ZoKKAJfLF7
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Wednesday 05 January 2005 10:30 am, Robert Olsson wrote:
> Jeremy M. Guthrie writes:
>  > Yeah, the load will be high.  I'm expecting this to be watching ~ 750
>  > mbps by next December.  The app profiles all traffic going in and out =
of
>  > our data centers.
>  BW itself or pps is that not much of challange as handling of concurrent
>  flows.
Roger that.

>  > I'm not showing the /proc/net/rt_cache_stat file.  Was there a kernel
>  > option I need to recompile with for rt_cache_stat to show up in proc?
>
>  No it's there without any options. Would be nice to the output from rtst=
at
Output from rtstat:
rtstat
fopen: No such file or directory

cd /proc/net/
ls -la
total 0
dr-xr-xr-x   5 root root 0 2005-01-04 08:53 .
dr-xr-xr-x  72 root root 0 2005-01-04 08:53 ..
=2Dr--r--r--   1 root root 0 2005-01-05 10:32 anycast6
=2Dr--r--r--   1 root root 0 2005-01-05 10:32 arp
dr-xr-xr-x   2 root root 0 2005-01-05 10:32 atm
=2Dr--r--r--   1 root root 0 2005-01-05 10:32 dev
=2Dr--r--r--   1 root root 0 2005-01-05 10:32 dev_mcast
dr-xr-xr-x   2 root root 0 2005-01-05 10:32 dev_snmp6
=2Dr--r--r--   1 root root 0 2005-01-04 08:53 if_inet6
=2Dr--r--r--   1 root root 0 2005-01-05 10:32 igmp
=2Dr--r--r--   1 root root 0 2005-01-05 10:32 igmp6
=2Dr--r--r--   1 root root 0 2005-01-05 10:32 ip6_flowlabel
=2Dr--r--r--   1 root root 0 2005-01-05 10:32 ip_mr_cache
=2Dr--r--r--   1 root root 0 2005-01-05 10:32 ip_mr_vif
=2Dr--r--r--   1 root root 0 2005-01-05 10:32 ip_tables_matches
=2Dr--r--r--   1 root root 0 2005-01-05 10:32 ip_tables_names
=2Dr--r--r--   1 root root 0 2005-01-05 10:32 ip_tables_targets
=2Dr--r--r--   1 root root 0 2005-01-05 10:32 ipv6_route
=2Dr--r--r--   1 root root 0 2005-01-05 10:32 mcfilter
=2Dr--r--r--   1 root root 0 2005-01-05 10:32 mcfilter6
=2Dr--r--r--   1 root root 0 2005-01-05 10:32 netlink
=2Dr--r--r--   1 root root 0 2005-01-05 10:32 netstat
=2Dr--r--r--   1 root root 0 2005-01-05 10:32 psched
=2Dr--r--r--   1 root root 0 2005-01-05 10:32 raw
=2Dr--r--r--   1 root root 0 2005-01-05 10:32 raw6
=2Dr--r--r--   1 root root 0 2005-01-05 10:32 route
dr-xr-xr-x   6 root root 0 2005-01-05 10:32 rpc
=2Dr--r--r--   1 root root 0 2005-01-05 10:32 rt6_stats
=2Dr--r--r--   1 root root 0 2005-01-05 10:32 rt_acct
=2Dr--r--r--   1 root root 0 2005-01-05 10:32 rt_cache
=2Dr--r--r--   1 root root 0 2005-01-05 10:32 snmp
=2Dr--r--r--   1 root root 0 2005-01-05 10:32 snmp6
=2Dr--r--r--   1 root root 0 2005-01-05 10:32 sockstat
=2Dr--r--r--   1 root root 0 2005-01-05 10:32 sockstat6
=2Dr--r--r--   1 root root 0 2005-01-05 10:32 softnet_stat
dr-xr-xr-x   2 root root 0 2005-01-05 10:32 stat
=2Dr--r--r--   1 root root 0 2005-01-04 08:53 tcp
=2Dr--r--r--   1 root root 0 2005-01-05 10:32 tcp6
=2Dr--r--r--   1 root root 0 2005-01-05 10:32 tr_rif
=2Dr--r--r--   1 root root 0 2005-01-04 08:53 udp
=2Dr--r--r--   1 root root 0 2005-01-05 10:32 udp6
=2Dr--r--r--   1 root root 0 2005-01-05 10:32 unix
=2Dr--r--r--   1 root root 0 2005-01-05 10:32 wireless

>  > >  Also check that the CPU shares the RX packet load. CPU0 affinty to
>  > > eth0 and CPU1 to eth1 seems to be best. It gives cache bouncing at
>  > > "TX" and slab jobs but we have accept that for now.
>  >
>  > How would I go about doing this?
>
>  Assume you route packets between eth0 <-> eth1
Yup

>  Set eth0 irq to CPU0 and eth1 to CPU1 with /proc/irq/XX/smp_affinity
Done

>  Disable irqbalancer etc.
Done

I'll let you know what I see for stats once I get some collected.

>  > cat /proc/net/softnet_stat
>
>  total    droppped tsquz    Throttl  FR_hit   FR_succe FR_defer FR_def_o
>  cpu_coll
>
>  > 5592c972 00000000 00001fc8 00000000 00000000 00000000 00000000 00000000
>  > 00391c3f
>  > 000f1991 00000000 00000000 00000000 00000000 00000000 00000000 00000000
>  > 001292ba
>
>  See! One line per CPU. So CPU0 is handing almost all packets.
cat /proc/interrupts
           CPU0       CPU1
  0:     674862   93484967    IO-APIC-edge  timer
  1:        564          9    IO-APIC-edge  i8042
  7:          0          0   IO-APIC-level  ohci_hcd
  8:          1          1    IO-APIC-edge  rtc
 12:        268         62    IO-APIC-edge  i8042
 14:          2          0    IO-APIC-edge  ide0
 18: 2105131410    9140835   IO-APIC-level  eth3
 20:       1077  248075156   IO-APIC-level  eth2
 27:     118224          1   IO-APIC-level  eth0
 28:      36298         49   IO-APIC-level  aic7xxx
 30:          0          0   IO-APIC-level  acpi
NMI:          0          0
LOC:   94168097   94168094
ERR:          0
MIS:          0

>  > "%soft"
>  > Show  the percentage of time spent by the CPU or CPUs to service
>  > softirqs.  A softirq (software interrupt) is one  of  up  to  32
>  > enumerated software interrupts which can run on multiple CPUs
>
>  Well yes. I had a more specific question. I'll look into mpstat where do
>  find it? Kernel pacthes?
Sorry about that.  New to the list.  I'm not suggesting anything.  I=20
appreciate the help!

Suse listed mpstat as part of sysstat 5.1.2.  I'm running stock 2.6.10.

>  Be also aware that packet forwarding with SMP/NUMA is very much research
>  today it is not that easy or not even possible to get aggregated
> performance from several CPU's. in any setup. Well anyway we are beginning
> to see some benefits now as we better understand the problems.
Understood.  As long as I know this, I can articulate this to my uppers for=
=20
bigger hardware.  My current system is a dual P-III 700mhz.  May be time fo=
r=20
an upgrade.  However, I figure this may also offer a good environment to he=
lp=20
provide you guys with a taxed system running an load of flows.  Nothing lik=
e=20
finding fun stuff while a system is ready to fall over.

Would a single hyper threaded CPU help this or should I default to a normal=
=20
dual-cpu system?

=2D-=20

=2D-------------------------------------------------
Jeremy M. Guthrie        jeremy.guthrie@berbee.com
Senior Network Engineer        Phone: 608-298-1061
Berbee                           Fax: 608-288-3007
5520 Research Park Drive         NOC: 608-298-1102
Madison, WI 53711

--nextPart2230455.ZoKKAJfLF7
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBB3CVHqtjaBHGZBeURAnY6AJ9bDuvkkdvq4Fz4e7cFE9fAwy69zwCfb5Yi
QuzCimWD5bzoT/f5J+D8DTk=
=XYHB
-----END PGP SIGNATURE-----

--nextPart2230455.ZoKKAJfLF7--
