From: Dave Hansen <haveblue@us.ibm.com>
Subject: Re: Update on e1000 troubles (over-heating!)
Date: Mon, 14 Oct 2002 22:42:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DABAACE.9040706@us.ibm.com>
References: <288F9BF66CD9D5118DF400508B68C44604758B78@orsmsx113.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'Ben Greear'" <greearb@candelatech.com>,
   linux-kernel <linux-kernel@vger.kernel.org>,
   "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Feldman, Scott wrote:
>>Here is the lspci information, both -x and -vv.  This is with 
>>two of the e1000 single-port NICS side-by-side.  I have also 
>>strapped a P-IV CPU fan on top of the two cards to blow some 
>>air over them....running tests now to see if that actually 
>>helps anything.  If it does, I'll be sure to send you a picture :)
> 
> Ben, I checked the datasheet for the part shown in the lspci dump, and it
> shows an operating temperature of 0-55 degrees C.  You said you measured 50
> degrees C, so you're within the safe range.  Did the fans help?
> 
> Here's the datasheet:
> http://www.intel.com/network/connectivity/resources/doc_library/data_sheets/
> pro1000mt_sa.pdf

I get some strange e1000 failures too.  It usually involves the 
watchdog kicking them back into order, but sometimes they'll stay 
offline for a while.  Heat would explain it, though, because it only 
happens when I'm actually using the cards for a benchmark.  I figured 
that it was either my cables, or a shoddy switch.

The new dual-port e1000 that I have doesn't seem to have this problem, 
even though I'm running 4 times more traffic than the singles that I 
had.
-- 
Dave Hansen
haveblue@us.ibm.com
