From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: RFC: NAPI packet weighting patch
Date: Fri, 27 May 2005 14:01:32 -0700
Message-ID: <20050527140132.1435132d@dxpl.pdx.osdl.net>
References: <Pine.CYG.4.58.0505261406210.2364@mawilli1-desk2.amr.corp.intel.com>
	<20050527085055.79da3d75@dxpl.pdx.osdl.net>
	<Pine.CYG.4.58.0505271305590.2148@mawilli1-desk2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, hadi@cyberus.ca, Robert.Olsson@data.slu.se,
        "Ronciak, John" <john.ronciak@intel.com>,
        "Venkatesan, Ganesh"
 <ganesh.venkatesan@intel.com>,
        "Brandeburg, Jesse"
 <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitch Williams <mitch.a.williams@intel.com>
In-Reply-To: <Pine.CYG.4.58.0505271305590.2148@mawilli1-desk2.amr.corp.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 27 May 2005 13:27:04 -0700
Mitch Williams <mitch.a.williams@intel.com> wrote:

> 
> Stephen, Robert, and Jamal all replied to my original message, and all
> said approximately the same thing:  "Why don't you just reduce the weight
> in the driver?  It does the same thing."
> 
> To which I reply, respectfully, I know that.  And no it doesn't, not
> exactly.
> 
> My primary reason for adding this setting is to allow for runtime tweaking
> -- just like max_backlog has right now.  Driver weight is a compile-time
> setting, and has to be changed for every driver that you run.
> 
> This setting allows you to scale the weight of all your drivers, at
> runtime, in one place.  It's complimentary to Stephen's max_weight idea --
> his patch affects how long you spend in any individual softirq; my patch
> affects how long you spend in any driver's individual NAPI poll routine,
> as well as how long the softirq lasts.
>

Why not just allow adjusting dev->weight via sysfs?
	
