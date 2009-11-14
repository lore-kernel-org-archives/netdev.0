From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] X25: Enable setting of cause and diagnostic fields
Date: Fri, 13 Nov 2009 20:32:48 -0800 (PST)
Message-ID: <20091113.203248.84989794.davem@davemloft.net>
References: <d45a3acc0911111613v38fa9df4jed21876ce6309097@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-x25@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: andrew.hendry@gmail.com
Return-path: <linux-x25-owner@vger.kernel.org>
In-Reply-To: <d45a3acc0911111613v38fa9df4jed21876ce6309097@mail.gmail.com>
Sender: linux-x25-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: andrew hendry <andrew.hendry@gmail.com>
Date: Thu, 12 Nov 2009 11:13:27 +1100

> Adds SIOCX25SCAUSEDIAG, allowing X.25 programs to set the cause and
> diagnostic fields.
> Normally used to indicate status upon closing connections.
> 
> Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

This change is incomplete.

You need to add handling to compat_x25_ioctl().
