From: "Scariah, Thomas" <Thomas.Scariah@harman.com>
Subject: RE: [EXTERNAL] Re: [PATCH 1/1] ethtool : added get_phy_stats,
  get_strings,get_sset_count
Date: Tue, 28 Mar 2017 06:45:46 +0000
Message-ID: <ad58864cd8d2474595010e6feccdb7b6@HIBDWSMB03.ad.harman.com>
References: <1490609570-3571-1-git-send-email-thomasscariah@gmail.com>
 <5153db09-092f-55b1-a8fc-aa23433c52a0@gmail.com>
 <20170327173835.GD17041@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Thomas Scariah <thomasscariah@gmail.com>,
        "nsekhar@ti.com" <nsekhar@ti.com>,
        "grygorii.strashko@ti.com" <grygorii.strashko@ti.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "drivshin@allworx.com" <drivshin@allworx.com>,
        "ivan.khoronzhuk@linaro.org" <ivan.khoronzhuk@linaro.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.bemta12.messagelabs.com ([216.82.251.16]:11440 "EHLO
        mail1.bemta12.messagelabs.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753889AbdC1Gpz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 02:45:55 -0400
In-Reply-To: <20170327173835.GD17041@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Andrew,
> > Hello,
> > 
> > On 03/27/2017 03:12 AM, Thomas Scariah wrote:
> > > From: "Scariah, Thomas" <thomas.scariah@harman.com>
> > > 
> > >  Added functions to support ethtool to print the phy statistics and 
> > > error  information along with other ethtool statistics. This will 
> > > help ethtool  information to know the error is from physical layer or MAC layer.
> > >  This is an enahancement for ethtool to accommodate phy statistics

> Hi Thomas
>
> What tree is this against? net-next already has get_phy_stats, get_strings, and get_sset_count in struct >phy_driver.
As I have mentioned I have developed against Kernel 4.4.14 and the similar functionality was not available. 

Regards and Thanks
Thomas Scariah


-----Original Message-----
From: Andrew Lunn [mailto:andrew@lunn.ch] 
Sent: Monday, March 27, 2017 11:09 PM
To: Florian Fainelli <f.fainelli@gmail.com>
Cc: Thomas Scariah <thomasscariah@gmail.com>; nsekhar@ti.com; grygorii.strashko@ti.com; davem@davemloft.net; drivshin@allworx.com; mugunthanvnm@ti.com; ivan.khoronzhuk@linaro.org; Scariah, Thomas <Thomas.Scariah@harman.com>; netdev@vger.kernel.org; linux-kernel@vger.kernel.org
Subject: [EXTERNAL] Re: [PATCH 1/1] ethtool : added get_phy_stats, get_strings,get_sset_count

On Mon, Mar 27, 2017 at 09:44:37AM -0700, Florian Fainelli wrote:
> Hello,
> 
> On 03/27/2017 03:12 AM, Thomas Scariah wrote:
> > From: "Scariah, Thomas" <thomas.scariah@harman.com>
> > 
> >  Added functions to support ethtool to print the phy statistics and 
> > error  information along with other ethtool statistics. This will 
> > help ethtool  information to know the error is from physical layer or MAC layer.
> >  This is an enahancement for ethtool to accommodate phy statistics

Hi Thomas

What tree is this against? net-next already has get_phy_stats, get_strings, and get_sset_count in struct phy_driver.

     Andrew
