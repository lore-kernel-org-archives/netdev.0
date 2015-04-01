From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: [PATCH RFCv2 0/4] batman-adv: Unicasting multicast reports
 to querier-node only
Date: Wed,  1 Apr 2015 10:04:35 +0200
Message-ID: <1427875479-9240-1-git-send-email-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
To: b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

The last round of multicast patches send to the batman-adv mailinglist
to add support for the multicast optimizations in bridged scenarios, too,
unfortunately had one major conceptual flaw: It could lead to packet loss=
.
It's not sufficient to have the unicasting of reports implemented on
bridge-nodes only. Nodes without bridges need to treat reports the same
way.

The issue is described in detail here:

https://www.open-mesh.org/projects/batman-adv/wiki/Multicast-optimization=
s-listener-reports


I'd also be interested in what the netdev/bridge people think about
patches #1 and #2 in particular, therefore including the according mailin=
glists
now.

Cheers, Linus


Changelog:
v2:
 * various bugfixes (now runtime tested, too - should(tm) work)
 * added netdev+bridge mailinglists
