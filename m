From: Andi Kleen <ak@suse.de>
Subject: Re: Update on e1000 troubles (over-heating!)
Date: Tue, 15 Oct 2002 04:37:23 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021015043722.A9562@wotan.suse.de>
References: <288F9BF66CD9D5118DF400508B68C44604758B78@orsmsx113.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'Ben Greear'" <greearb@candelatech.com>,
   linux-kernel <linux-kernel@vger.kernel.org>,
   "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
Content-Disposition: inline
In-Reply-To: <288F9BF66CD9D5118DF400508B68C44604758B78@orsmsx113.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Oct 14, 2002 at 07:20:04PM -0700, Feldman, Scott wrote:
> > Here is the lspci information, both -x and -vv.  This is with 
> > two of the e1000 single-port NICS side-by-side.  I have also 
> > strapped a P-IV CPU fan on top of the two cards to blow some 
> > air over them....running tests now to see if that actually 
> > helps anything.  If it does, I'll be sure to send you a picture :)
> 
> Ben, I checked the datasheet for the part shown in the lspci dump, and it
> shows an operating temperature of 0-55 degrees C.  You said you measured 50
> degrees C, so you're within the safe range.  Did the fans help?

The thermometer he used likely showed a much lower temperature than what was 
actually on the die. 5-10 C more are not unlikely. It's hard to measure chip
temperatures accurately without an on die thermal diode or special kit.
So I would expect that when an external normal thermometer showed 50C 
it was already operating out of spec.

-Andi
