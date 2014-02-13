From: Stefan =?ISO-8859-1?Q?S=F8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: Re: [PATCH v2 2/2] dp83640: Get pin and master/slave configuration
 from DT
Date: Thu, 13 Feb 2014 15:23:23 +0100
Message-ID: <1392301403.2585.11.camel@e37108.spectralink.com>
References: <1392132562-23644-1-git-send-email-stefan.sorensen@spectralink.com>
	 <1392132562-23644-3-git-send-email-stefan.sorensen@spectralink.com>
	 <20140211201917.GB4254@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <grant.likely@linaro.org>, <robh+dt@kernel.org>,
	<mark.rutland@arm.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <devicetree@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140211201917.GB4254@netboy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-02-11 at 21:19 +0100, Richard Cochran wrote:
> > +- dp83640,slave: If present, this phy will be slave to another dp83640
> > +  on the same mdio bus.
> 
> Wouldn't it be more natural to have one "dp83640,master" property
> rather than multiple slave properties?

I wanted to keep the common case of a single phy simple, i.e. no need to
specify any master/slave properties. 

> Most of these pr_err lines are a bit _way_ too long for coding style.

I will fix that in the next version.

Stefan
