From: Mirko Lindner <demon@pro-linux.de>
Subject: Re: [PATCH]sk98lin ethtool support
Date: Fri, 02 Jan 2004 14:23:10 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FF57ECE.5020107@pro-linux.de>
References: <Pine.LNX.4.44.0401012352180.11808-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, krishnakumar@naturesoft.net,
        mlindner@syskonnect.de, netdev@oss.sgi.com, felix@allot.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
In-Reply-To: <Pine.LNX.4.44.0401012352180.11808-100000@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Feldman, Scott wrote:
> On Tue, 30 Dec 2003, Mirko Lindner wrote:
> 
> 
>>>Make sure you don't duplicate any ethtool functions.  We don't need a
>>>NIC-specific diag tool either ;-)  ethtool is the preferred method
>>>moving forward, as it's already shipping in most Linux distros.
>>
>>Yes, we need it ;) No kidding! This is not a tool for SW checks like
>>media, link or driver version checks, but a tool for HW checks like
>>register, PROM, MAC, PHY and some other chip and card checks. The
>>ethtool is a great tool, but the intention of this tool is not the same.
> 
> 
> If the tool reports the results of running the h/w checks, then you can 
> use ETHTOOL_TEST.  The summary results of all the tests is reported as 
> PASS/FAIL.  Not sure if your tool needs to do more...
> 
> -scott
> 
> 
> 
> 
> <!DSPAM:3ff51cdf53311090219406>
> 

Scott,

thanks for this info, but the tool reports not only the status, but also 
the results of a test (Example: "Register 0xxxx=xxx", PROM info...). 
"Problem" 2: All tests are included in the DIAG tool and not in the 
driver. We have approx. 100 separate tests (over 1000 individual tests) 
and the driver is huge enough (Support for Genesis, Yukon, Yukon-Lite, 
Yukon-Plus and Yukon2 chipsets).

Mirko
