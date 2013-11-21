From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] wimax: remove dead code
Date: Thu, 21 Nov 2013 08:27:30 +0100
Message-ID: <1385018850.14273.0.camel@jlt4.sipsolutions.net>
References: <1385005391-18379-1-git-send-email-michael.opdenacker@free-electrons.com>
	 <1385007469.2164.39.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michael Opdenacker <michael.opdenacker@free-electrons.com>,
	inaky.perez-gonzalez@intel.com, linux-wimax@intel.com,
	davem@davemloft.net, wimax@linuxwimax.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1385007469.2164.39.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-11-20 at 20:17 -0800, Joe Perches wrote:
> On Thu, 2013-11-21 at 04:43 +0100, Michael Opdenacker wrote:
> > This removes a code line that is between a "return 0;" and an error label.
> > This code line can never be reached.
> 
> Adding Johannes Berg who added this oversight.

Obviously, sorry about that. I seem to remember deleting *something*
there (like another error label) but I guess I missed that line.

Acked-by: Johannes Berg <johannes@sipsolutions.net>

johannes
