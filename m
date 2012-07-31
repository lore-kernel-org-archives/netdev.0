From: Robert Engels <rengels@optionscity.com>
Subject: cpu usage on blocking network call
Date: Tue, 31 Jul 2012 14:14:01 -0500
Message-ID: <CA+q+rD2O8dkBhgxCsHVsq=j7zi56nb9D59gYHHA=uOKbnZZdSQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:61151 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751508Ab2GaTOC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2012 15:14:02 -0400
Received: by vbbff1 with SMTP id ff1so6136315vbb.19
        for <netdev@vger.kernel.org>; Tue, 31 Jul 2012 12:14:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have a strange problem, and was hoping the developers could provide
some insight.

I have tested with ubuntu 12.04, with the 3.2.0-23 lowlatency kernel.
I also tested with a 3.0.31 vanilla realtime kernel on a different
machine.

I open a blocking socket (and connect to a remote client), and start
two threads, a reader and a writer.

I pump LOTS of data down the writer, but do not receive any data on
the reader (by design).

The reader thread is reporting some CPU usage (not a lot, about 10% of
the writer cpu). I determine this using "top", and other profiling
tools.

I also run strace on the thread, and it shows that it is blocked in
read() call, and that is doesn't return.

Why/How is the reader thread consuming CPU? Poorly written driver?
Kernel bug? Or is this expected behavior or the kernel?

I am more than willing to spend more time tracking it down in the
kernel, but I'd like some direction.

--

Robert Engels
OptionsCity Software Inc.
Chicago, IL
