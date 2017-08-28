From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [PATCH 1/6] ACPI: make device_attribute const
Date: Mon, 28 Aug 2017 22:56:08 +0200
Message-ID: <34210940.RKebigQkUC@aspire.rjw.lan>
References: <1503315792-14837-1-git-send-email-bhumirks@gmail.com> <1503315792-14837-2-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: julia.lawall@lip6.fr, lenb@kernel.org, jbacik@fb.com,
        jikos@kernel.org, benjamin.tissoires@redhat.com,
        manish.chopra@cavium.com, rahul.verma@cavium.com,
        Dept-GELinuxNICDev@cavium.com, harish.patil@cavium.com,
        cascardo@holoscopio.com, don@syst.com.br, dvhart@infradead.org,
        andy@infradead.org, sre@kernel.org, linux-acpi@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-block@vger.kernel.org,
        nbd-general@lists.sourceforge.net, linux-input@vger.kernel.org,
        netdev@vger.kernel.org, platform-driver-x86@vger.kernel.org,
        linux-pm@vger.kernel.org
To: Bhumika Goyal <bhumirks@gmail.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1503315792-14837-2-git-send-email-bhumirks@gmail.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, August 21, 2017 1:43:07 PM CEST Bhumika Goyal wrote:
> Make these const as they are only passed as an argument to the function
> device_create_file and device_remove_file and the corresponding
> arguments are of type const.
> Done using Coccinelle
> 
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
> ---
>  drivers/acpi/battery.c | 2 +-
>  drivers/acpi/sbs.c     | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/acpi/battery.c b/drivers/acpi/battery.c
> index 1cbb88d..13e7b56 100644
> --- a/drivers/acpi/battery.c
> +++ b/drivers/acpi/battery.c
> @@ -620,7 +620,7 @@ static ssize_t acpi_battery_alarm_store(struct device *dev,
>  	return count;
>  }
>  
> -static struct device_attribute alarm_attr = {
> +static const struct device_attribute alarm_attr = {
>  	.attr = {.name = "alarm", .mode = 0644},
>  	.show = acpi_battery_alarm_show,
>  	.store = acpi_battery_alarm_store,
> diff --git a/drivers/acpi/sbs.c b/drivers/acpi/sbs.c
> index a184637..a2428e9 100644
> --- a/drivers/acpi/sbs.c
> +++ b/drivers/acpi/sbs.c
> @@ -474,7 +474,7 @@ static ssize_t acpi_battery_alarm_store(struct device *dev,
>  	return count;
>  }
>  
> -static struct device_attribute alarm_attr = {
> +static const struct device_attribute alarm_attr = {
>  	.attr = {.name = "alarm", .mode = 0644},
>  	.show = acpi_battery_alarm_show,
>  	.store = acpi_battery_alarm_store,
> 

Applied, thanks!


