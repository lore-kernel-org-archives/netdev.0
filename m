From: 'Greg Kroah-Hartman' <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 09/15] net: can: Convert to use devm_ioremap_resource
Date: Tue, 11 Jun 2013 20:09:41 -0700
Message-ID: <20130612030941.GA10250@kroah.com>
References: <1370864113-17895-1-git-send-email-tushar.behera@linaro.org>
 <1370864113-17895-10-git-send-email-tushar.behera@linaro.org>
 <51B5D007.8050005@pengutronix.de>
 <51B69663.5080304@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
	linux-kernel@vger.kernel.org, thierry.reding@gmail.com,
	patches@linaro.org, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, Wolfgang Grandegger <wg@grandegger.com>
To: Tushar Behera <tushar.behera@linaro.org>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <51B69663.5080304@linaro.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 11, 2013 at 08:45:47AM +0530, Tushar Behera wrote:
> +CC: 'Greg Kroah-Hartman' <gregkh@linuxfoundation.org>
> 
> On 06/10/2013 06:39 PM, Marc Kleine-Budde wrote:
> > On 06/10/2013 01:35 PM, Tushar Behera wrote:
> >> Commit 75096579c3ac ("lib: devres: Introduce devm_ioremap_resource()")
> >> introduced devm_ioremap_resource() and deprecated the use of
> >> devm_request_and_ioremap().
> > 
> > Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>
> > 
> > Are the patches going over the individual subsystem maintainers?
> > 
> > Marc
> > 
> 
> I am not sure. Looping in Greg for clarity.

I'm taking the ones for my subsystem(s), the last one should probably go
in after 3.11-rc1 is released, in order to ensure no remaining in-tree
users of the function are still around.

thanks,

greg k-h
