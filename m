From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v2 8/9] Altera TSE: Add Miscellaneous Files for
 Altera Ethernet Driver
Date: Mon, 10 Mar 2014 17:40:31 -0700
Message-ID: <20140310174031.4145a3ff@nehalam.linuxnetplumber.net>
References: <1394493277-2105-1-git-send-email-vbridgers2013@gmail.com>
	<1394493277-2105-9-git-send-email-vbridgers2013@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, rob@landley.net
To: Vince Bridgers <vbridgers2013@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1394493277-2105-9-git-send-email-vbridgers2013@gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 10 Mar 2014 18:14:36 -0500
Vince Bridgers <vbridgers2013@gmail.com> wrote:

> +
> +	buf[0] = (u64) ioread32(&mac->frames_transmitted_ok);

The cast to u64 is not really necessary, C will do it for you.
You do need the cast to do the shift for the 64 bit values.
