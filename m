From: "John W. Linville" <linville@tuxdriver.com>
Subject: wireless: recap of current issues (other issues)
Date: Fri, 13 Jan 2006 17:24:09 -0500
Message-ID: <20060113222408.GM16166@tuxdriver.com>
References: <20060113195723.GB16166@tuxdriver.com> <20060113212605.GD16166@tuxdriver.com> <20060113213237.GH16166@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1423027AbWAMWYT@vger.kernel.org>
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060113213237.GH16166@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Other Issues
============

Radiotap headers make sense for an rfmon virtual device.  I don't
think it makes sense for "normal" usage.  Should there be an option
for radiotap headers on non-rfmon links?

Rfmon interferes w/ other interfaces, but may be handy to enter/leave
w/ little effort.  Perhaps a config option for physical device to
suspend/resume all (non-rfmon) virtual devices before/after enabling
rfmon virtual device?  (Would multiple rfmon devices even make sense?
If not, is it worth restricting that?)

What about old hardware w/ inactive maintenance?  Deprecate/remove?
Grandfather them w/ treatment as ethernet devices?  Probably don't
need a pronouncement on this at this time...
-- 
John W. Linville
linville@tuxdriver.com
