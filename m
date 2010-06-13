From: Alex Riesen <raa.lkml@gmail.com>
Subject: Re: read(2) hangs waiting for data from a closed socket
Date: Sun, 13 Jun 2010 21:55:40 +0200
Message-ID: <AANLkTinudiZQ9ZVi6nSBD-dkcEGXJhwYzt1tScTYn8eU@mail.gmail.com>
References: <20100613152348.GA1794@arch.tripp.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100613152348.GA1794@arch.tripp.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 13, 2010 at 17:23, Markus Trippelsdorf
<markus@trippelsdorf.de> wrote:
> Just revert commit 597a264b1a9c7e36d1728f677c66c5c1f7e3b837 for now.
> See also: http://lkml.org/lkml/2010/6/12/37

I see. Thanks! Reverting the commit indeed fixes the conky/hddtemp problem.
