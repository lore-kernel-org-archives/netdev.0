From: Daniel Phillips <phillips@phunq.net>
Subject: Re: Distributed storage.
Date: Fri, 3 Aug 2007 17:41:18 -0700
Message-ID: <200708031741.18404.phillips@phunq.net>
References: <20070731171347.GA14267@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070731171347.GA14267@2ka.mipt.ru>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Evgeniy,

Nit alert:

On Tuesday 31 July 2007 10:13, Evgeniy Polyakov wrote:
>     * storage can be formed on top of remote nodes and be exported
> 	simultaneously (iSCSI is peer-to-peer only, NBD requires device
> 	mapper and is synchronous)

In fact, NBD has nothing to do with device mapper.  I use it as a 
physical target underneath ddraid (a device mapper plugin) just like I 
would use your DST if it proves out.

Regards,

Daniel
