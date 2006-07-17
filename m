From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] sky2: NAPI poll fix
Date: Mon, 17 Jul 2006 13:27:55 -0400
Message-ID: <44BBC89B.1080201@pobox.com>
References: <20060717095434.7c6277f6@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57003 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751084AbWGQR16 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2006 13:27:58 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060717095434.7c6277f6@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> When sky2 driver gets lots of received packets at once, it can get stuck.
> The NAPI poll routine gets called back to keep going, but since no IRQ bits
> are set it doesn't make progress.
> 
> Increase version, since this is serious enough problem that I want to be
> able to tell new from old problems.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

applied


