From: Kevin Smith <kevin.smith@elecsyscorp.com>
Subject: Re: [PATCH net-next 7/9] net: dsa: mv88e6xxx: restore VLANTable map
 control
Date: Fri, 26 Feb 2016 20:45:28 +0000
Message-ID: <56D0B964.4090002@elecsyscorp.com>
References: <1456510568-13679-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1456510568-13679-8-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kernel@savoirfairelinux.com" <kernel@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Neil Armstrong <narmstrong@baylibre.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Russell King <rmk+kernel@arm.linux.org.uk>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456510568-13679-8-git-send-email-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Content-ID: <A09C442420252148AAF47F002923ECA3@dciincorporated.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Vivien,

On 02/26/2016 12:16 PM, Vivien Didelot wrote:
> +	/* allow CPU port or DSA link(s) to send frames to every port */
> +	if (dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)) {
> +		output_ports = mask;
> +	} else {
Is this always correct?  Are there situations where a CPU or neighboring 
switch should not be allowed to access another port? (e.g. Figure 6 or 7 
in the 88E6352 functional specification).

Thanks,
Kevin
