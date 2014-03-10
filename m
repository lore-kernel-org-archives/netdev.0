From: Robert Stonehouse <rstonehouse@solarflare.com>
Subject: Re: sfc 0000:05:00.0 eth4: pci_enable_pcie_error_reporting failed
 (-5)
Date: Mon, 10 Mar 2014 09:08:40 +0000
Message-ID: <531D8118.3080304@solarflare.com>
References: <CALCETrX0tn7WjTqnuQ5v+ZUJoJO2bbSb-ykzX5A3yssXKys8fg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
To: Andy Lutomirski <luto@amacapital.net>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Network Development <netdev@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	Shradha Shah <sshah@solarflare.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <CALCETrX0tn7WjTqnuQ5v+ZUJoJO2bbSb-ykzX5A3yssXKys8fg@mail.gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/03/2014 18:17, Andy Lutomirski wrote:
> I think this is because my machine sets the FIRMWARE_FIRST flag.
> Should this message be downgraded to KERN_INFO or even KERN_DEBUG?

Yes; Thanks for the info on FIRMWARE_FIRST. I hadn't looked into the 
reasons for pci_enable_pcie_error_reporting() failing
I think this message is just noise in most cases, and I will try and 
have it downgraded in the next Solarflare patches sent.

Rob
