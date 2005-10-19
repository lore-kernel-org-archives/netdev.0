From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [patch 2.6.14-rc4 0/3] sk98lin: neuter and prepare for removal
Date: Tue, 18 Oct 2005 21:41:03 -0400
Message-ID: <20051019014101.GC6687@tuxdriver.com>
References: <10182005213059.12304@bilbo.tuxdriver.com> <4355A390.9090309@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com, mlindner@syskonnect.de, rroesler@syskonnect.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932454AbVJSBlP@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <4355A390.9090309@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 18, 2005 at 06:38:24PM -0700, Stephen Hemminger wrote:
> John W. Linville wrote:
> 
> >These patches take steps towards removing sk98lin from the upstream
> >kernel.
> >
> >	-- Remove sk98lin's MODULE_DEVICE_TABLE to avoid
> >	confusing userland tools about which driver to load;

> I applaud the initiative, but this it is too premature to obsolete the 
> existing driver. There may be lots of chip versions and other variables 
> that make
> the existing driver a better choice.  Maybe eepro100 is a better target
> for removal right now.

That's cool...but I still think the first one (removing the
MODULE_DEVICE_TABLE) is worthwhile.  At least that gets more testers
for skge.

What do you think?

John
-- 
John W. Linville
linville@tuxdriver.com
