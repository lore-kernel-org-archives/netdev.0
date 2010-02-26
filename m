From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2 5/7] pci: Add helper to search for VPD keywords
Date: Fri, 26 Feb 2010 20:49:11 +0000
Message-ID: <1267217351.2098.19.camel@achroite.uk.solarflarecom.com>
References: <1267216838-19459-6-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jbarnes@virtuousgeek.org, linux-pci@vger.kernel.org,
	netdev@vger.kernel.org, andy@greyhouse.net,
	Michael Chan <mchan@broadcom.com>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1267216838-19459-6-git-send-email-mcarlson@broadcom.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2010-02-26 at 12:40 -0800, Matt Carlson wrote:
> This patch adds the pci_vpd_find_info_keyword() helper function to
> find information field keywords within read-only and read-write large
> resource data type sections.
[...]
> +/**
> + * pci_vpd_find_info_keyword - Locates an information field keyword in the VPD
> + * @buf: Pointer to buffered vpd data
> + * @off: The offset into the buffer at which to begin the search
> + * @len: The length of the buffer area, relative to off, in which to search
> + * @kw: The keyword to search for
> + *
> + * Returns the index where the information field keyword was found or
> + * -ENOENT otherwise.
> + */
> +int pci_vpd_find_info_keyword(u8 *buf, unsigned int off,
> +			      unsigned int len, char *kw);
[...]

The kw pointer should be const-qualified.  The buf pointers could also
be const-qualified though this is less important.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
