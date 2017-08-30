From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH 5/6] platform/x86: make device_attribute const
Date: Wed, 30 Aug 2017 22:18:29 +0300
Message-ID: <CAHp75VfohACiOR7XGd5o7LOMPQdDarfgN8HqvEqcg_oiCf-+VA@mail.gmail.com>
References: <1503315792-14837-1-git-send-email-bhumirks@gmail.com> <1503315792-14837-6-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Julia Lawall <julia.lawall@lip6.fr>,
        "Rafael J. Wysocki" <rjw@rjwysocki.net>,
        Len Brown <lenb@kernel.org>, Josef Bacik <jbacik@fb.com>,
        Jiri Kosina <jikos@kernel.org>,
        Benjamin Tissoires <benjamin.tissoires@redhat.com>,
        manish.chopra@cavium.com, rahul.verma@cavium.com,
        Dept-GELinuxNICDev@cavium.com, harish.patil@cavium.com,
        cascardo@holoscopio.com, don@syst.com.br,
        "dvhart@infradead.org" <dvhart@infradead.org>,
        Andy Shevchenko <andy@infradead.org>,
        Sebastian Reichel <sre@kernel.org>,
        "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        linux-block@vger.kernel.org, nbd-general@lists.sourceforge.net,
        linux-input <linux-input@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        Platform Driver <
To: Bhumika Goyal <bhumirks@gmail.com>
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <1503315792-14837-6-git-send-email-bhumirks@gmail.com>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 21, 2017 at 2:43 PM, Bhumika Goyal <bhumirks@gmail.com> wrote:
> Make these const as they are only passed as an argument to the
> function device_create_file and device_remove_file and the corresponding
> arguments are of type const.
> Done using Coccinelle
>

Split on per driver basis.

> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
> ---
>  drivers/platform/x86/classmate-laptop.c | 6 +++---
>  drivers/platform/x86/intel-rst.c        | 4 ++--
>  2 files changed, 5 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/platform/x86/classmate-laptop.c b/drivers/platform/x86/classmate-laptop.c
> index 55cf10b..d3715e2 100644
> --- a/drivers/platform/x86/classmate-laptop.c
> +++ b/drivers/platform/x86/classmate-laptop.c
> @@ -254,7 +254,7 @@ static ssize_t cmpc_accel_sensitivity_store_v4(struct device *dev,
>         return strnlen(buf, count);
>  }
>
> -static struct device_attribute cmpc_accel_sensitivity_attr_v4 = {
> +static const struct device_attribute cmpc_accel_sensitivity_attr_v4 = {
>         .attr = { .name = "sensitivity", .mode = 0660 },
>         .show = cmpc_accel_sensitivity_show_v4,
>         .store = cmpc_accel_sensitivity_store_v4
> @@ -303,7 +303,7 @@ static ssize_t cmpc_accel_g_select_store_v4(struct device *dev,
>         return strnlen(buf, count);
>  }
>
> -static struct device_attribute cmpc_accel_g_select_attr_v4 = {
> +static const struct device_attribute cmpc_accel_g_select_attr_v4 = {
>         .attr = { .name = "g_select", .mode = 0660 },
>         .show = cmpc_accel_g_select_show_v4,
>         .store = cmpc_accel_g_select_store_v4
> @@ -599,7 +599,7 @@ static ssize_t cmpc_accel_sensitivity_store(struct device *dev,
>         return strnlen(buf, count);
>  }
>
> -static struct device_attribute cmpc_accel_sensitivity_attr = {
> +static const struct device_attribute cmpc_accel_sensitivity_attr = {
>         .attr = { .name = "sensitivity", .mode = 0660 },
>         .show = cmpc_accel_sensitivity_show,
>         .store = cmpc_accel_sensitivity_store
> diff --git a/drivers/platform/x86/intel-rst.c b/drivers/platform/x86/intel-rst.c
> index 7344d84..760a9bf 100644
> --- a/drivers/platform/x86/intel-rst.c
> +++ b/drivers/platform/x86/intel-rst.c
> @@ -65,7 +65,7 @@ static ssize_t irst_store_wakeup_events(struct device *dev,
>         return count;
>  }
>
> -static struct device_attribute irst_wakeup_attr = {
> +static const struct device_attribute irst_wakeup_attr = {
>         .attr = { .name = "wakeup_events", .mode = 0600 },
>         .show = irst_show_wakeup_events,
>         .store = irst_store_wakeup_events
> @@ -111,7 +111,7 @@ static ssize_t irst_store_wakeup_time(struct device *dev,
>         return count;
>  }
>
> -static struct device_attribute irst_timeout_attr = {
> +static const struct device_attribute irst_timeout_attr = {
>         .attr = { .name = "wakeup_time", .mode = 0600 },
>         .show = irst_show_wakeup_time,
>         .store = irst_store_wakeup_time
> --
> 1.9.1
>



-- 
With Best Regards,
Andy Shevchenko
