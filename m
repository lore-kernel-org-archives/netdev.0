From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH] ieee80211: Update generic definitions to latest specs.
Date: Fri, 3 Jun 2005 11:33:43 +0200
Message-ID: <20050603113343.55d19cfc@griffin.suse.cz>
References: <20050602190232.340996282D7@mail.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>, <jbohac@suse.cz>
Return-path: <netdev-bounce@oss.sgi.com>
To: <gwingerde@home.nl>
In-Reply-To: <20050602190232.340996282D7@mail.suse.cz>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2 Jun 2005 21:02:24 +0200, gwingerde@home.nl wrote:
> I was thinking about that too, but couldn't find a proper shorter
> version without losing the descriptive meaning.
> 
> Do you have any suggestions to shorten them?

Maybe we can lose a bit of descriptiveness and put comments above
definitions instead?

I can imagine names such as WLAN_STATUS_ASSOC_DENIED_NOSPECTRUM,
WLAN_STATUS_ASSOC_DENIED_BAD_POWER,
WLAN_STATUS_ASSOC_DENIED_BAD_SUPPCHANNS, WLAN_REASON_DISASSOC_BAD_POWER,
and so on. Also WLAN_STATUS_ASSOC_DENIED_NOSHORT seems to be acceptable
for me.

More often used identifiers probably could have even shorter name - what
about renaming IEEE80211_FCTL_PROTECTEDFRAME to
IEEE80211_FCTL_PROTECTED?

Thanks,

-- 
Jiri Benc
SUSE Labs
