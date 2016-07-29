From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v5 4/8] thunderbolt: Communication with the ICM (firmware)
Date: Fri, 29 Jul 2016 14:48:38 -0700
Message-ID: <20160729214838.GA14827@kroah.com>
References: <1469693721-5641-1-git-send-email-amir.jer.levy@intel.com>
 <1469693721-5641-5-git-send-email-amir.jer.levy@intel.com>
 <20160729140224.137dbaac@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Amir Levy <amir.jer.levy@intel.com>, andreas.noever@gmail.com,
	bhelgaas@google.com, corbet@lwn.net, linux-kernel@vger.kernel.org,
	linux-pci@vger.kernel.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, thunderbolt-linux@intel.com,
	mika.westerberg@intel.com, tomas.winkler@intel.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160729140224.137dbaac@xeon-e3>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 29, 2016 at 02:02:24PM -0700, Stephen Hemminger wrote:
> On Thu, 28 Jul 2016 11:15:17 +0300
> Amir Levy <amir.jer.levy@intel.com> wrote:
> 
> > +static LIST_HEAD(controllers_list);
> > +static DECLARE_RWSEM(controllers_list_rwsem);
> 
> Why use a semaphore when simple spinlock or mutex would be better?

And never use a RW semaphore unless you can benchmark the difference
from a normal lock.  If you can't benchmark it, then don't use it...
