From: Matthew Garrett <mjg59@srcf.ucam.org>
Subject: Re: Network drivers that don't suspend on interface down
Date: Thu, 21 Dec 2006 02:18:32 +0000
Message-ID: <20061221021832.GA723@srcf.ucam.org>
References: <20061220042648.GA19814@srcf.ucam.org> <20061220144906.7863bcd3@dxpl.pdx.osdl.net> <20061221011209.GA32625@srcf.ucam.org> <200612202105.31093.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Arjan van de Ven <arjan@infradead.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161147AbWLUCSq@vger.kernel.org>
To: Michael Wu <flamingice@sourmilk.net>
Content-Disposition: inline
In-Reply-To: <200612202105.31093.flamingice@sourmilk.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 20, 2006 at 09:05:27PM -0500, Michael Wu wrote:

> Softmac isn't the only wireless code that likes to be configured after going 
> up first. Configuring after the card goes up has generally been more 
> reliable, though that should not be necessary and is a bug IMHO. 

Ok, that's nice to know. 

> In order to scan, we need to have the radio on and we need to be able to send 
> and receive. What are you gonna turn off?

The obvious route would be to power the card down, but come back up 
every two minutes to perform a scan, or if userspace explicitly requests 
one. Would this cause problems in some cases?

-- 
Matthew Garrett | mjg59@srcf.ucam.org
