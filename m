From: Karol Lewandowski <karol.k.lewandowski@gmail.com>
Subject: Re: [E1000-devel] [BUG 2.6.30+] e100 sometimes causes oops during
	resume
Date: Wed, 16 Sep 2009 11:19:11 +0200
Message-ID: <20090916091911.GA1496@bizet.domek.prywatny>
References: <20090915120538.GA26806@bizet.domek.prywatny> <13830B75AD5A2F42848F92269B11996F5BF592C3@orsmsx509.amr.corp.intel.com> <20090916014448.GA1070@bizet.domek.prywatny>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Graham, David" <david.graham@intel.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Karol Lewandowski <karol.k.lewandowski@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758256AbZIPJTQ@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090916014448.GA1070@bizet.domek.prywatny>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 16, 2009 at 03:44:48AM +0200, Karol Lewandowski wrote:
> On Tue, Sep 15, 2009 at 03:54:20PM -0700, Graham, David wrote:
> 
> > A v2.6.30..v2.6.31 diff shows that this is probably exposed by
> > Rafael Wysocki's commit 6905b1f1, which now allows systems with e100
> > to sleep. If I understand correctly, it looks like these systems
> > simply couldn't sleep before. Is that right Rafael?.
> 
> Probably true, but that wasn't the case for my (I guess
> ACPI-controlled) system.
> 
> 
> > I don't think its likely that the commit is a direct cause of the
> > problem, but that the suspend/resume cycle now allows us to see
> > another issue.
> 
> From my (very limited) understanding commit message is at least in
> conflict with patch body.

No, it isn't, I must just go to bed earlier than 4AM. :/

Sorry for noise.
