From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: netdev->mem_start, etc
Date: Tue, 25 Nov 2003 09:53:57 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031125095357.72a06e17.rddunlap@osdl.org>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0102CBDCF9@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E0102CBDCF9@orsmsx402.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 25 Nov 2003 09:50:50 -0800 "Feldman, Scott" <scott.feldman@intel.com> wrote:

| Is there any reason why these fields should be set for a PCI nic driver?
| 
|   netdev->mem_start
|   netdev->mem_end
|   netdev->base_addr
| 
| They seem to be vestigial.  
| 
| (I'm trying to prune a e100/e1000 dependency with a app that's matching
| on these fields to figure out PCI device ID).


In several drivers mem_start has been overloaded to pass something
often called 'options', like media type, connector, auto-negotiate,
duplex, etc. settings.

--
~Randy
MOTD:  Always include version info.
