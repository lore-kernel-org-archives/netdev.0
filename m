From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 3/3] rx_all e100 patch
Date: Tue, 25 Nov 2003 10:05:24 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FC399E4.2080509@candelatech.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0102CBDCF8@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E0102CBDCF8@orsmsx402.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Feldman, Scott wrote:
> Ben, I'd rather not touch e100-2.3.x as it's going to be replaced soon
> with e100-3.0.x.  Can you switch over to e100-3.0.x for this
> development?  It's up on the sf.net/projects/e1000 web site.  I think
> you'll find this patch collapses into much fewer lines with the new
> driver.  It has ethtool_ops support also.  I can work on the e100-3.0.x
> patch if you don't want to redo the work.  Let me know.
> 
> -scott
> 


When is 3.0.X destined to hit 2.4?  My personal priority is to
get a patch that works against vanilla 2.4.$CURRENT, so I'll need to follow
it in my own patch set.

However, late-night typos aside, the changes to e100 are quite trivial,
so I imagine you could make the changes in very short time to your
other driver(s).  I have to ship my own patchset for other features
anyway, so one more doesn't hinder me too badly, ie if this takes
a while to become mainline, that's ok.

If we can get the ethtool and flags changes in soon, it will also
be easy for you to do the testing, as ethereal works out-of-the-box.
Dave seems interested, and the flags & ethtool changes are relatively
trivial as well, so hopefully these will go in sometime soon.

PS.  Scott, is there an e1000 document similar to the e100 one available?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
