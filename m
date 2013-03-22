From: Masatake YAMATO <yamato@redhat.com>
Subject: Re: [PATCH 2/2] thermal: shorten too long mcast group name
Date: Fri, 22 Mar 2013 12:43:06 +0900 (JST)
Message-ID: <20130322.124306.147839510158679545.yamato@redhat.com>
References: <20130320.120832.24140728832512231.davem@davemloft.net>
	<20130321.164623.197949072785579777.yamato@redhat.com>
	<20130321.105324.1538473102849136394.davem@davemloft.net>
        <20130321.190819.892238877314124764.yamato@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-acpi@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <20130321.105324.1538473102849136394.davem@davemloft.net>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry for cross posting to netdev and linux-acpi.

I submitted almost same patch about thermal subsystem both netdev list
and then linux-acpi list.

http://marc.info/?l=linux-netdev&m=136371412725264&w=2
http://marc.info/?l=linux-acpi&m=136386050309109&w=2

After submitting to linux-acpi list, I noticed the patch
is merged to a tree davem maintained.

What I should do?

The submitted pathes are bit different.
In netdev, I proposed changing "thermal_mc_group" to
"thermal_mc_grp". In linux-acpi I proposed changing 
"thermal_mc_group" to "thermal_mc_grou".

"thermal_mc_grp" is easier to read. However, when thinking
about compatibility, "thermal_mc_grou" is better.

I've already submitted another patch for genl command which 
truncates the C string returned from kernel.

http://marc.info/?l=linux-netdev&m=136371412625262&w=2

Consider a situation(A); using old kernel(without my patch submitted for linux-acpi)
and new genl command (with my patch for genl). You will get

   thermal_mc_grou

as output.


Consider anther situation(B); using new kernel(with my patch submitted for 
linux-acpi) and old genl command (without my patch for genl). You will get

   thermal_mc_grou

as output. In both situations(A and B) users can get the same output.
If you choose "thermal_mc_grp", users may see "thermal_mc_grp" or
"thermal_mc_grou".

>>> From: Masatake YAMATO <yamato@redhat.com>
>>> Date: Tue, 19 Mar 2013 20:47:28 +0900
>>> 
>>>> The original name is too long.
>>>> 
>>>> Signed-off-by: Masatake YAMATO <yamato@redhat.com>
>>> 
>>> This change needs to go in via the Thermal driver maintainers.
>> 
>> Thanks. I've submitted the patch to linux-acpi ML.
> 
> I already applied the patch to my tree, didn't you read
> the rest of this thread?

I read but I didn't understand the meaning of applying because
I cannot find my 2nd patch for thermal in net-next tree when I 
pulled.

What I should do? Should I withdraw the patch submitted to 
linux-acpi?

However, I slight modified the patch when I submitted it to 
linux-acpi.

> And in the future, order your patches such that you fix the bug before
> adding the assertion.

Sorry. I'll do so next time.

Masatake YAMATO
