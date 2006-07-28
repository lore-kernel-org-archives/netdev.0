From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: SMSC LAN911x and LAN921x vendor driver
Date: Fri, 28 Jul 2006 07:31:22 -0700
Message-ID: <20060728073122.3b7baafe@localhost>
References: <20060714115035.502d8edf@dxpl.pdx.osdl.net>
	<11540873333102-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ian Saturley <ian.saturley@smsc.com>,
	Bahadir Balban <Bahadir.Balban@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:12462 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751984AbWG1Obk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2006 10:31:40 -0400
To: Steve Glendinning <steve.glendinning@smsc.com>
In-Reply-To: <11540873333102-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> +/* Tasklet declarations */
> +static unsigned long rx_tasklet_parameter;
> +static void smsc911x_rx_tasklet(unsigned long data);
> +
> +DECLARE_TASKLET(rx_tasklet, smsc911x_rx_tasklet, 0);

You can make this local with
static DECLARE_TASKLET(rx_tasklet, smsc911x_rx_tasklet, 0);
