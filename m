From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net 4/4] net/mlx4_en: get rid of private net_device_stats
Date: Thu, 26 May 2016 12:58:34 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D5F4C6374@AcuExch.aculab.com>
References: <1464195039-5098-1-git-send-email-edumazet@google.com>
 <1464195039-5098-5-git-send-email-edumazet@google.com>
 <6320ccdc-d369-c08c-c959-6c8ed9b88d10@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: 'Tariq Toukan' <ttoukan.linux@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.188]:60917 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753721AbcEZNAB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 09:00:01 -0400
In-Reply-To: <6320ccdc-d369-c08c-c959-6c8ed9b88d10@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan
> Sent: 26 May 2016 10:39
...
> I am aware that clearing the stats structure might be redundant today,
> as the function is called only within mlx4_en_open, but we might want to
> call the function in other flows in the future.

My personal view is that stats should never be cleared.
Any code that wants stats deltas should be remembering the old
values itself.

For SNMP (etc) you may want to save the time when the stats block
was created (when everything would be zero).

	David
