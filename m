From: Olof Johansson <olof@austin.ibm.com>
Subject: Re: [2.4] e1000 leaking pci mappings on rx errors?
Date: Mon, 12 Jan 2004 18:35:36 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40033D58.1080604@austin.ibm.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0102229CCD@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, cramerj <cramerj@intel.com>, milliner@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E0102229CCD@orsmsx402.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Feldman, Scott wrote:

> Ok, most of the changes to the driver are on the Tx side.  Add this to
> 5.2.20 and let's see if we're hitting this path.  Maybe there is still
> something wrong with the Tx unwind case where we run out of resources:

It looks like I temporarily lost the machine, but I could give it one 
run before it happened. It was bursting huge number of those messages, 
but I had no chance to correlate them to the number of mappings that 
were leaked, since the machine pretty much locked up (serial console + 
too much kernel printks = very very slow machine).


-Olof

-- 
Olof Johansson                                        Office: 4F005/905
pSeries Linux Development                             IBM Systems Group
Email: olof@austin.ibm.com                          Phone: 512-838-9858
All opinions are my own and not those of IBM
