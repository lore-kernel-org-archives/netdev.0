From: Joerg Reuter <jreuter@yaina.de>
Subject: Re: [PATCH 04/24] ax25: Remove unnecessary OOM logging messages
Date: Tue, 30 Aug 2011 00:42:00 +0200
Message-ID: <20110829224159.GB23854@yaina.de>
References: <cover.1314650069.git.joe@perches.com>
 <a426e678426cf2be1552edfbbb0de7ce08e9a7ef.1314650069.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ralf Baechle <ralf@linux-mips.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-hams-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <a426e678426cf2be1552edfbbb0de7ce08e9a7ef.1314650069.git.joe@perches.com>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 29, 2011 at 02:17:23PM -0700, Joe Perches wrote:

> Removing unnecessary messages saves code and text.

Not really that much of an impact, but yes, I agree it just swamps
syslog with duplicate messages... It was more debug code than
anything else originally. Beats me why it is logged as KERN_ERR or
KERN_CRIT, being out of buffers is not really fatal or even
unusual.

Still alive with just not enough time for hamradio stuff nowadays,
	Joerg DL1BKE

-- 
Joerg Reuter                                    http://yaina.de/jreuter
And I make my way to where the warm scent of soil fills the evening air. 
Everything is waiting quietly out there....                 (Anne Clark)

