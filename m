From: Quantum Scientific <Info@quantum-sci.com>
Subject: Re: Kernel 2.6 IPV6 Busted
Date: Sun, 27 Feb 2005 14:10:39 -0600
Message-ID: <200502271410.39611.Info@quantum-sci.com>
References: <200502270928.44402.Info@Quantum-Sci.com> <200502271310.59682.Info@quantum-sci.com> <42222670.3090002@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com
In-Reply-To: <42222670.3090002@pobox.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Are you not understanding that I need to receive packets back?  I am not going 
to open incoming firewall ports to do this.  If you have a way to receive 
IPV6 response packets back without opening up your firewall, please enlighten 
us.

This is a problem everyone else has too, if they are using the standard kernel 
2.6 IPV6 stack.

I am skeptical about this assertion that the whole internet needs to be hashed 
if connection tracking.  This does not seem to be true on its face.  Only 
those nodes which are in active virtual circuits would need to be hashed.  
This is well within most machines' capability.  So barring some inherent IPV6 
way of doing this, connection tracking is on.

Carl Cook



On Sunday 27 February 2005 13:58, Jeff Garzik wrote:
> Quantum Scientific wrote:
> > On Sunday 27 February 2005 12:59, Jeff Garzik wrote:
> > 
> >>Connection tracking doesn't scale.  It's impossible to hash the entire 
> >>Internet.
> > 
> > 
> > I have read this.  
> > 
> > And I've seen inferences that IPV6 takes care of this problem somehow 
> > automatically.  But no one seems to know how.
> 
> The solution is to not use connection tracking.
> 
> You don't want to break the end-to-end connection model that founded the 
> Internet.
> 
>  Jeff
