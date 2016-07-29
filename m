From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v5 4/8] thunderbolt: Communication with the ICM
 (firmware)
Date: Fri, 29 Jul 2016 14:03:26 -0700
Message-ID: <20160729140326.1fae0ced@xeon-e3>
References: <1469693721-5641-1-git-send-email-amir.jer.levy@intel.com>
	<1469693721-5641-5-git-send-email-amir.jer.levy@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: andreas.noever@gmail.com, gregkh@linuxfoundation.org,
	bhelgaas@google.com, corbet@lwn.net, linux-kernel@vger.kernel.org,
	linux-pci@vger.kernel.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, thunderbolt-linux@intel.com,
	mika.westerberg@intel.com, tomas.winkler@intel.com
To: Amir Levy <amir.jer.levy@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1469693721-5641-5-git-send-email-amir.jer.levy@intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 28 Jul 2016 11:15:17 +0300
Amir Levy <amir.jer.levy@intel.com> wrote:

> +int nhi_send_message(struct tbt_nhi_ctxt *nhi_ctxt, enum pdf_value pdf,
> +		     u32 msg_len, const u8 *msg, bool ignore_icm_resp)
> +{

Why not make msg a void * and not have to do so many casts?
