From: Dmitry Yusupov <dima@neterion.com>
Subject: Re: UDP optimization
Date: Fri, 25 Feb 2005 11:17:57 -0800
Message-ID: <1109359077.13087.64.camel@beastie>
References: <46548.69.93.110.242.1109328682.squirrel@69.93.110.242>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
To: shabanip <shabanip@avapajoohesh.com>
In-Reply-To: <46548.69.93.110.242.1109328682.squirrel@69.93.110.242>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As far as UDP HW acceleration is concerned we need to modify/verify that
Linux TCP/IP stack capable of:

1) Partial checksumming on receive
2) Checksumming over fragments on transmit

And find the NIC which capable of doing that. s2io/neterion hw do
supports those features.

Regards,
Dima

Without those two, I doubt you will 

On Fri, 2005-02-25 at 14:21 +0330, shabanip wrote:
> as i know there are many ways to optimize and tune TCP parameters in kernel
> but how can i tune and optimize UDp performance?
> thanks,
> Payam Shabanian
> shabanip -at- avapajoohesh.com
