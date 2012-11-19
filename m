From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 04/10] batman-adv: export compatibility
 version via debugfs
Date: Mon, 19 Nov 2012 14:47:45 -0500 (EST)
Message-ID: <20121119.144745.1093556126398582629.davem@davemloft.net>
References: <1353313451-2930-5-git-send-email-ordex@autistici.org>
 <1353351150.4156.4.camel@bwh-desktop.uk.solarflarecom.com>
 <5268262.CIrZ93ERtB@bentobox>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org, lindner_marek-LWAfsSFWpa4@public.gmane.org
To: sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <5268262.CIrZ93ERtB@bentobox>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Date: Mon, 19 Nov 2012 20:29:07 +0100

> On Monday 19 November 2012 18:52:30 Ben Hutchings wrote:
>> On Mon, 2012-11-19 at 09:24 +0100, Antonio Quartulli wrote:
>> > Different versions of the batman-adv module may use the same compatibility
>> > version, but this is not understandable at runtime (the only way is to
>> > parse the kernel log and fetch the batman-adv advertisement message on
>> > loading). The user may want to know whether two nodes using different
>> > versions can communicate or not. For this purpose the module has to
>> > export this value through debugfs.
>> [...]
>> 
>> I do hope that you're not planning to use unstable debugfs interfaces
>> indefinitely.
> 
> Why are you refering to the adding of an file as "incompatible" debugfs 
> interface? I would call it additional information. And the rest of the commit 
> message is talking about *possible* protocol incompatibilies of the network 
> protocol (which caused this uncontrolled erruption of anger in a network 
> maintainer).

Debugfs files aren't where you store information that userspace actually
uses in normal situations.

It's for developer debug, to expose internals that otherwise have no
business being part of the user visible interfaces.
