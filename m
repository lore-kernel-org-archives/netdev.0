From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: Strange commit 42a73808ed4f30b739eb52bcbb33a02fe62ceef5
Date: Thu, 31 Jan 2008 13:27:39 +0300
Message-ID: <47A1A29B.9000509@openvz.org>
References: <20080130175508.GC29368@does.not.exist>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Denis Lunev <den@openvz.org>
To: Adrian Bunk <bunk@kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:55087 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753929AbYAaK1w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2008 05:27:52 -0500
In-Reply-To: <20080130175508.GC29368@does.not.exist>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adrian Bunk wrote:
> Commit 42a73808ed4f30b739eb52bcbb33a02fe62ceef5
> ("[RAW]: Consolidate proc interface.") did not only change raw6_seq_ops
> (including adding 3 EXPORT_SYMBOL_GPL's to net/ipv4/raw.c for accessing 
> functions from there), it also removed the only user of raw6_seq_ops...

The commit is not strange it is wrong :( Sorry David, when I checked
the according proc files, I saw that both files show sockets, but
overlooked that the raw6 one shows the ipv4 part of the ipv6 socket.

Denis noticed that this morning and has already prepared a fix.
So please, do not revert the commit, the fix will be at your mailbox today.

Thanks, Adrian.

> cu
> Adrian
> 

