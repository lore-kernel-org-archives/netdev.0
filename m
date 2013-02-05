From: Dhanasekaran Anbalagan <bugcy013@gmail.com>
Subject: Re: How to enable Adaptive RX on
Date: Tue, 5 Feb 2013 15:14:08 -0500
Message-ID: <CAJzooYdDQ4hHEpeJ+XV=+QvpqBST5r53RuY8R-4Y9=1xyAGwmw@mail.gmail.com>
References: <CAJzooYfqO64TgrswgrpHw5VmzeO_XveGUDy7tPQ0s4+zsnKO0A@mail.gmail.com>
	<1360092001.2857.3.camel@bwh-desktop.uk.solarflarecom.com>
	<CAJzooYfgPcpakMigNH8hk1OavzTe0SiHxpM=_6FL--Rm0HmfBg@mail.gmail.com>
	<1360094065.2857.20.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5494808597038093352=="
Cc: e1000-devel <e1000-devel@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1360094065.2857.20.camel@bwh-desktop.uk.solarflarecom.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

--===============5494808597038093352==
Content-Type: multipart/alternative; boundary=f46d043d64b360a20804d4ffdb76

--f46d043d64b360a20804d4ffdb76
Content-Type: text/plain; charset=UTF-8

Hi Bean,

Is there any specific modules here, we need enable the coalescing,  with
our kernel so the Adaptive RX turn on.

please guide me.

-Dhanasekaran.

Did I learn something today? If not, I wasted it.


On Tue, Feb 5, 2013 at 2:54 PM, Ben Hutchings <bhutchings@solarflare.com>wrote:

> On Tue, 2013-02-05 at 14:23 -0500, Dhanasekaran Anbalagan wrote:
> > Hi we have the following
> >
> > root@dvcl150:~# ethtool -i eth0
> > driver: igb
> > version: 3.2.10-k
> > firmware-version: 1.6-1
> > bus-info: 0000:04:00.0
> > supports-statistics: yes
> > supports-test: yes
> > supports-eeprom-access: yes
> > supports-register-dump: yes
>
> This driver doesn't support adaptive RX IRQ coalescing.  It should
> report an error when you try to enable it, but currently just ignores
> that setting.
>
> Ben.
>
>
> --
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
>

--f46d043d64b360a20804d4ffdb76--


--===============5494808597038093352==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Free Next-Gen Firewall Hardware Offer
Buy your Sophos next-gen firewall before the end March 2013 
and get the hardware for free! Learn more.
http://p.sf.net/sfu/sophos-d2d-feb
--===============5494808597038093352==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============5494808597038093352==--
