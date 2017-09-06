From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH 3/6] hid: make device_attribute const
Date: Wed, 6 Sep 2017 10:57:29 +0200 (CEST)
Message-ID: <nycvar.YFH.7.76.1709061057200.4077@jbgna.fhfr.qr>
References: <1503315792-14837-1-git-send-email-bhumirks@gmail.com> <1503315792-14837-4-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: julia.lawall@lip6.fr, rjw@rjwysocki.net, lenb@kernel.org,
        jbacik@fb.com, benjamin.tissoires@redhat.com,
        manish.chopra@cavium.com, rahul.verma@cavium.com,
        Dept-GELinuxNICDev@cavium.com, harish.patil@cavium.com,
        cascardo@holoscopio.com, don@syst.com.br, dvhart@infradead.org,
        andy@infradead.org, sre@kernel.org, linux-acpi@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-block@vger.kernel.org,
        nbd-general@lists.sourceforge.net, linux-input@vger.kernel.org,
        netdev@vger.kernel.org, platform-driver-x86@vger.kernel.org,
        linux-pm@vger.kernel.org
To: Bhumika Goyal <bhumirks@gmail.com>
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <1503315792-14837-4-git-send-email-bhumirks@gmail.com>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 21 Aug 2017, Bhumika Goyal wrote:

> Make this const as it is only passed as an argument to the
> function device_create_file and device_remove_file and the corresponding
> arguments are of type const.
> Done using Coccinelle
> 
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
> ---
>  drivers/hid/hid-core.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/hid/hid-core.c b/drivers/hid/hid-core.c
> index 9bc9116..24e929c 100644
> --- a/drivers/hid/hid-core.c
> +++ b/drivers/hid/hid-core.c
> @@ -1662,7 +1662,7 @@ static bool hid_hiddev(struct hid_device *hdev)
>  	.size = HID_MAX_DESCRIPTOR_SIZE,
>  };
>  
> -static struct device_attribute dev_attr_country = {
> +static const struct device_attribute dev_attr_country = {
>  	.attr = { .name = "country", .mode = 0444 },
>  	.show = show_country,

Applied, thanks.

-- 
Jiri Kosina
SUSE Labs

