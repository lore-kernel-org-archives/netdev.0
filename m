From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 37992] New: It's not possible to compile
 kernel if CONFIG_NETCONSOLE_DYNAMIC is turned on
Date: Mon, 20 Jun 2011 12:28:35 -0700
Message-ID: <20110620122835.444f16d7.akpm@linux-foundation.org>
References: <bug-37992-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, hilld@binarystorm.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:42767 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752344Ab1FTT2k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 15:28:40 -0400
In-Reply-To: <bug-37992-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Mon, 20 Jun 2011 19:09:49 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=37992
> 
>            Summary: It's not possible to compile kernel if
>                     CONFIG_NETCONSOLE_DYNAMIC is turned on
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 3.0-rc3+
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: hilld@binarystorm.net
>         Regression: No
> 
> 
> Hello guys,
> 
>     It's not possible to compile kernel if CONFIG_NETCONSOLE_DYNAMIC is turned
> on ...
> 
> drivers/built-in.o: In function `netconsole_target_put':
> /usr/src/linux-3.0/drivers/net/netconsole.c:133: undefined reference to
> `config_item_put'
> drivers/built-in.o: In function `netconsole_target_get':
> /usr/src/linux-3.0/drivers/net/netconsole.c:127: undefined reference to
> `config_item_get'
> drivers/built-in.o: In function `netconsole_target_put':
> /usr/src/linux-3.0/drivers/net/netconsole.c:133: undefined reference to
> `config_item_put'
> drivers/built-in.o: In function `netconsole_target_get':
> /usr/src/linux-3.0/drivers/net/netconsole.c:127: undefined reference to
> `config_item_get'
> drivers/built-in.o: In function `netconsole_target_put':
> /usr/src/linux-3.0/drivers/net/netconsole.c:133: undefined reference to
> `config_item_put'
> drivers/built-in.o: In function `drop_netconsole_target':
> /usr/src/linux-3.0/drivers/net/netconsole.c:588: undefined reference to
> `config_item_put'
> drivers/built-in.o: In function `make_netconsole_target':
> /usr/src/linux-3.0/drivers/net/netconsole.c:561: undefined reference to
> `config_item_init_type_name'
> drivers/built-in.o: In function `dynamic_netconsole_init':
> /usr/src/linux-3.0/drivers/net/netconsole.c:109: undefined reference to
> `config_group_init'
> /usr/src/linux-3.0/drivers/net/netconsole.c:111: undefined reference to
> `configfs_register_subsystem'
> drivers/built-in.o: In function `dynamic_netconsole_exit':
> /usr/src/linux-3.0/drivers/net/netconsole.c:116: undefined reference to
> `configfs_unregister_subsystem'
> make: *** [.tmp_vmlinux1] Error 1

