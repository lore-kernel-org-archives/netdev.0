From: Arend van Spriel <arend@broadcom.com>
Subject: Re: [PATCH resend] README: clarify redistribution requirements covering
 patents
Date: Thu, 14 May 2015 20:29:46 +0200
Message-ID: <5554E99A.5030302@broadcom.com>
References: <1431626160-10885-1-git-send-email-mcgrof@do-not-panic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <kyle@kernel.org>, <linux-firmware@kernel.org>,
	<netdev@vger.kernel.org>, <linux-wireless@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <gnomes@lxorguk.ukuu.org.uk>,
	"Luis R. Rodriguez" <mcgrof@suse.com>
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1431626160-10885-1-git-send-email-mcgrof@do-not-panic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/14/15 19:56, Luis R. Rodriguez wrote:
> From: "Luis R. Rodriguez"<mcgrof@suse.com>
>
> Firmware licenses on linux-firmware should include an implicit
> or explicit patent grant to end users for full device operation
> otherwise it would start making linux-firmware useless for many
> Linux distributions which have positions against patent encumbered
> software [0] [1] [2] and it would mean cherry picking firmware files
> out. It can also mean making it problematic to redistribute linux-firmware
> in some jurisdictions which could have different positions on
> patents, or have already outlawed software patents.
>
> Licenses with implicit patent grants are allowed given that otherwise
> we couldn't carry permissively licensed firmwares which would be silly,
> but using permissively licensed firmware files which remove patent
> grants explicitly are not allowed.
>
> A clarifications is needed as one attempt was already made to include
> firmware encumbered by patents without a grant [3] and it was decided
> we would not allow these. We clarify this to make this requirement
> explicit and prevent these type of further attempts.
>
> [0] https://www.debian.org/legal/patent
> [1] http://fedoraproject.org/wiki/Software_Patents#Red_Hat.27s_position_on_Software_Patents
> [2] http://www.openinventionnetwork.com/about-us/
> [3] https://lkml.org/lkml/2014/3/14/182
>
> Cc: netdev@vger.kernel.org
> Cc: linux-wireless@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Signed-off-by: Luis R. Rodriguez<mcgrof@suse.com>
> ---
>
> This patch is unmodified, the discussion over it was brief [0] but I didn't
> hear back from Alan on this. Sending again now that we have a new active
> linux-firmware maintainer.
>
> [0] https://lkml.org/lkml/2014/6/27/448
>
>   README | 5 ++++-
>   1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/README b/README
> index f2ed92e..d2a56ec 100644
> --- a/README
> +++ b/README
> @@ -18,7 +18,10 @@ and also cc: to related mailing lists.
>
>   Your commit should include an update to the WHENCE file clearly
>   identifying the licence under which the firmware is available, and
> -that it is redistributable. If the licence is long and involved, it's
> +that it is redistributable. Being redistributable includes ensuring
> +the firmware license provided includes an implicit or explicit
> +patent grant to end users to ensure full functionality of device
> +operation with the firmware. If the licence is long and involved, it's

Just nitpicking here, but there is 'license' and 'licence' being used 
here. Better stick to one and preferably 'license'.

Regards,
Arend

>   permitted to include it in a separate file and refer to it from the
>   WHENCE file.
>   And if it were possible, a changelog of the firmware itself.
