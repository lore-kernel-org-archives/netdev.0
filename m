From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6 35/47] e1000: do vlan cleanup
Date: Wed, 20 Jul 2011 21:08:27 +0200
Message-ID: <20110720190825.GC2688@minipsycho.redhat.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
	<1311173689-17419-36-git-send-email-jpirko@redhat.com>
	<CAEP_g=-XJaq6KSwXXUzeFcqAo3WVWHCLyuqGYjcriRQiKO56bw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	bruce.w.allan@intel.com, jesse.brandeburg@intel.com,
	mirqus@gmail.com, john.ronciak@intel.com,
	shemminger@linux-foundation.org, davem@davemloft.net
To: Jesse Gross <jesse@nicira.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <CAEP_g=-XJaq6KSwXXUzeFcqAo3WVWHCLyuqGYjcriRQiKO56bw@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Wed, Jul 20, 2011 at 07:48:32PM CEST, jesse@nicira.com wrote:
>On Wed, Jul 20, 2011 at 7:54 AM, Jiri Pirko <jpirko@redhat.com> wrote:
>> @@ -4532,9 +4539,8 @@ static void e1000_vlan_rx_register(struct net_devi=
ce *netdev,
>>
>> =A0 =A0 =A0 =A0if (!test_bit(__E1000_DOWN, &adapter->flags))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0e1000_irq_disable(adapter);
>> - =A0 =A0 =A0 adapter->vlgrp =3D grp;
>>
>> - =A0 =A0 =A0 if (grp) {
>> + =A0 =A0 =A0 if (vlan_on) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* enable VLAN tag insert/strip */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ctrl =3D er32(CTRL);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ctrl |=3D E1000_CTRL_VME;
>
>Same comment here as with the igb driver.

The driver behaviour remains intact here.


---------------------------------------------------------------------------=
---
10 Tips for Better Web Security
Learn 10 ways to better secure your business today. Topics covered include:
Web security, SSL, hacker attacks & Denial of Service (DoS), private keys,
security Microsoft Exchange, secure Instant Messaging, and much more.
http://www.accelacomm.com/jaw/sfnl/114/51426210/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.co=
m/community/wired
