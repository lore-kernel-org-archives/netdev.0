From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: Network driver test suite?
Date: Wed, 12 Jan 2005 10:21:29 -0800
Message-ID: <41E56AA9.2060800@osdl.org>
References: <20050105152635.290ad9c0@dxpl.pdx.osdl.net>	<1105493554.28674.49.camel@bullpen.pdx.osdl.net>	<1105547064.5940.5.camel@dhollis-lnx.centricconsulting.com>	<1105550041.28674.53.camel@bullpen.pdx.osdl.net> <20050112101001.20ccc59d@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Craig Thomas <craiger@osdl.org>, David Hollis <dhollis@davehollis.com>,
        netdev@oss.sgi.com, cliff white <cliffw@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050112101001.20ccc59d@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Wed, 12 Jan 2005 09:14:01 -0800
> Craig Thomas <craiger@osdl.org> wrote:
> 
> 
>>On Wed, 2005-01-12 at 08:24, David Hollis wrote:
>>
>>>On Tue, 2005-01-11 at 17:32 -0800, Craig Thomas wrote:
>>>
>>>
>>>>Would there be a desire for someone to collect the tests or at least
>>>>create an index to all their locations?  If so, then developers can
>>>>scan a library of potential tests to run against newly developed code.
>>>>
>>>>OSDL can start incorporating some of these tests into their test
>>>>platform as well.
>>>
>>>I would love to see a collection of the types of tests that should be
>>>performed.  As it appears now, there is nothing defined that a driver
>>>author should do to verify that their driver performs properly, or
>>>supports the right capabilities etc.  Some things may be difficult to
>>>automate, but simply having a checklist would be great.  For the things
>>>that can be automated, that would be even better.
>>
>>Great.  We can do some of this.  I would like to ask, what mimimal
>>types of tests do you expect to execute for a driver?  If several
>>can respond to the types of testing they perform, we can start
>>a checklist.  Then, additional items can be added to fill in the
>>holes.  I've asked Cliff White of OSDL to help put this together.
> 
> 
> There are two types of tests that would be easy to set up.
> First is a full exercise of all the possible API transitions through
> ifconfig, ip link, and ethtool. These could be covered without any
> traffic going through.
> 
> Then setup a standard test environment with a known good card and a
> crossover cable.  The test could then use raw (and/or packet generator)
> to send packets down good card to card to be verified.
> 
> Also testing, auto negotiation and transitions under load.

Other than API testing, stats interface testing, & link/speed 
verification, the most useful test that I ever did in NIC driver
development (Natl Semi & Intel) was just traffic saturation:
copy and compare files for hours, log (and optionally stop on)
compare errors.

-- 
~Randy
