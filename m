From: Roland Dreier <rdreier@cisco.com>
Subject: [ofa-general] Re: [PATCH RFC] iw_cxgb3: Support "iwarp-only"
	interfaces to avoid 4-tuple conflicts with the host stack.
Date: Thu, 30 Aug 2007 21:27:04 -0700
Message-ID: <adaveawwcpz.fsf@cisco.com>
References: <1187905185.5547.13.camel@stevo-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ewg@lists.openfabrics.org,
	general@lists.openfabrics.org, linux-kernel@vger.kernel.org
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1187905185.5547.13.camel@stevo-desktop> (Steve Wise's message of
	"Thu, 23 Aug 2007 16:39:45 -0500")
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

 > The sysadmin creates "for iwarp use only" alias interfaces of the form
 > "devname:iw*" where devname is the native interface name (eg eth0) for the
 > iwarp netdev device.  The alias label can be anything starting with "iw".
 > The "iw" immediately after the ':' is the key used by the iwarp driver.

What's wrong with my suggestion of having the iwarp driver create an
"iwX" interface to go with the normal "ethX" interface?  It seems
simpler to me, and there's a somewhat similar precedent with how
mac80211 devices create both wlan0 and wmaster0 interfaces.

 - R.
