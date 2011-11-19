From: Marc Haber <mh+debian-bugs@zugschlus.de>
Subject: Bug#645308: tg3 broken for NetXtreme 5714S in squeeze 6.0.3 installer
Date: Sat, 19 Nov 2011 19:45:36 +0100
Message-ID: <20111119184536.GE4187@torres.zugschlus.de>
References: <20111018142056.GF29261@torres.zugschlus.de>
 <1319084914.23980.96.camel@deadeye>
 <20111021090046.GA13930@torres.zugschlus.de>
 <20111021090811.GA5993@torres.zugschlus.de>
 <1319199579.2918.42.camel@deadeye>
 <20111024212409.GA29764@mcarlson.broadcom.com>
 <1319500074.31243.47.camel@deadeye>
 <20111026002032.GA31575@mcarlson.broadcom.com>
 <1319614904.11727.17.camel@deadeye>
 <20111118195435.GA31807@mcarlson.broadcom.com>
Reply-To: Marc Haber <mh+debian-bugs@zugschlus.de>, 645308@bugs.debian.org
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Ben Hutchings <ben@decadent.org.uk>, Michael Chan <mchan@broadcom.com>,
	netdev <netdev@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>, 645308@bugs.debian.org
Return-path: <bounce-debian-bugs-dist=glddb-debian-bugs-dist=m.gmane.org@lists.debian.org>
Resent-Message-ID: <handler.645308.B645308.1321728345921@bugs.debian.org>
Content-Disposition: inline
In-Reply-To: <20111118195435.GA31807@mcarlson.broadcom.com>
List-Post: <mailto:debian-bugs-dist@lists.debian.org>
List-Help: <mailto:debian-bugs-dist-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=unsubscribe>
List-Id: netdev.vger.kernel.org

On Fri, Nov 18, 2011 at 11:54:35AM -0800, Matt Carlson wrote:
> I think I misspoke earlier.  The commit I mentioned above fixes a problem
> introduced in an earlier patch.  (commit ID
> d2394e6bb1aa636f3bd142cb6f7845a4332514b5, entitled
> "tg3: Always turn on APE features in mac_mode reg")  So the fact that
> 2.6.32-35 works and 2.6.32-36 doesn't means you applied the problematic
> patch that had the bug, but you didn't apply the above fix to correct it.

I can try a fixed kernel, but I don't understand the way Debian builds
its kernels. I can

(a) download a Debian kernel source package, apply
d2394e6bb1aa636f3bd142cb6f7845a4332514b5 and go the make; make install
way or
(b) wait for a kernel deb from Ben.

If (a) is expected to give reasonable results, I can do that.

Greetings
Marc

-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Mannheim, Germany  |  lose things."    Winona Ryder | Fon: *49 621 31958061
Nordisch by Nature |  How to make an American Quilt | Fax: *49 621 31958062
