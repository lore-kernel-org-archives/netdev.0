From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: RFC: Linux wireless extensions and WPA support
Date: Tue, 8 Jun 2004 09:58:12 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040608165812.GA16595@bougret.hpl.hp.com>
References: <386CBF9421521B41835E2BF21BEF80B8919069@hasmsx402.ger.corp.intel.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Jouni Malinen <jkmaline@cc.hut.fi>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Andonieh, Joe" <joe.andonieh@intel.com>
Content-Disposition: inline
In-Reply-To: <386CBF9421521B41835E2BF21BEF80B8919069@hasmsx402.ger.corp.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jun 08, 2004 at 10:36:25AM +0300, Andonieh, Joe wrote:
> #define IW_AUTH_WPA_VERSION	0
> ---
> #define IW_AUTH_WPA_VERSION_DISABLED	0
> #define IW_AUTH_WPA_VERSION_WPA		1
> #define IW_AUTH_WPA_VERSION_WPA2	2
> ---
> #define IW_AUTH_CIPHER_PAIRWISE	1
> #define IW_AUTH_CIPHER_GROUP	2
> ---
> #define IW_AUTH_CIPHER_NONE	0
> #define IW_AUTH_CIPHER_WEP40	1
> #define IW_AUTH_CIPHER_TKIP	2
> #define IW_AUTH_CIPHER_CCMP	4
> #define IW_AUTH_CIPHER_WEP104	5
> 
> I wonder how this definition let you differentiate between the unicast
> cipher and the group cipher?

	Yes : PAIRWISE vs. GROUP.

> Moreover there is two information that are
> needed
> 
> 1) the authentication model, which is PSK or .1x
> 2) The cipher to connect with? 
> 	Shall we set both Pair wise and Group or only Pairwise and
> connect with what ever group cipher in the RSN IE -- hint this will
> enable smooth connection to mixed mode networks?

	Those things are in Jouni's original proposal, and I don't
intend to drop them. I quoted only a small snipset, to clarify, please
refer to his e-mail to get the full picture.

> Please let me know what you think?
> 
> Thanks
> Joe

	Regards,

	Jean
